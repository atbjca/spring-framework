/*
 * Copyright 2002-2021 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.web.server.session;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.stream.IntStream;

import org.junit.jupiter.api.Test;
import reactor.core.scheduler.Schedulers;

import org.springframework.beans.DirectFieldAccessor;
import org.springframework.web.server.WebSession;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatIllegalStateException;

/**
 * Unit tests for {@link InMemoryWebSessionStore}.
 * @author Rob Winch
 */
public class InMemoryWebSessionStoreTests {

	private InMemoryWebSessionStore store = new InMemoryWebSessionStore();


	@Test
	public void startsSessionExplicitly() {
		WebSession session = this.store.createWebSession().block();
		assertThat(session).isNotNull();
		session.start();
		assertThat(session.isStarted()).isTrue();
	}

	@Test
	public void startsSessionImplicitly() {
		WebSession session = this.store.createWebSession().block();
		assertThat(session).isNotNull();
		session.start();
		session.getAttributes().put("foo", "bar");
		assertThat(session.isStarted()).isTrue();
	}

	@Test // gh-24027, gh-26958
	public void createSessionDoesNotBlock() {
		this.store.createWebSession()
				.doOnNext(session -> assertThat(Schedulers.isInNonBlockingThread()).isTrue())
				.block();
	}

	@Test
	public void retrieveExpiredSession() {
		WebSession session = this.store.createWebSession().block();
		assertThat(session).isNotNull();
		session.getAttributes().put("foo", "bar");
		session.save().block();

		String id = session.getId();
		WebSession retrieved = this.store.retrieveSession(id).block();
		assertThat(retrieved).isNotNull();
		assertThat(retrieved).isSameAs(session);

		// Fast-forward 31 minutes
		this.store.setClock(Clock.offset(this.store.getClock(), Duration.ofMinutes(31)));
		WebSession retrievedAgain = this.store.retrieveSession(id).block();
		assertThat(retrievedAgain).isNull();
	}

	@Test
	public void lastAccessTimeIsUpdatedOnRetrieve() {
		WebSession session1 = this.store.createWebSession().block();
		assertThat(session1).isNotNull();
		String id = session1.getId();
		Instant time1 = session1.getLastAccessTime();
		session1.start();
		session1.save().block();

		// Fast-forward a few seconds
		this.store.setClock(Clock.offset(this.store.getClock(), Duration.ofSeconds(5)));

		WebSession session2 = this.store.retrieveSession(id).block();
		assertThat(session2).isNotNull();
		assertThat(session2).isSameAs(session1);
		Instant time2 = session2.getLastAccessTime();
		assertThat(time1.isBefore(time2)).isTrue();
	}

	@Test // SPR-17051
	public void sessionInvalidatedBeforeSave() {
		// Request 1 creates session
		WebSession session1 = this.store.createWebSession().block();
		assertThat(session1).isNotNull();
		String id = session1.getId();
		session1.start();
		session1.save().block();

		// Request 2 retrieves session
		WebSession session2 = this.store.retrieveSession(id).block();
		assertThat(session2).isNotNull();
		assertThat(session2).isSameAs(session1);

		// Request 3 retrieves and invalidates
		WebSession session3 = this.store.retrieveSession(id).block();
		assertThat(session3).isNotNull();
		assertThat(session3).isSameAs(session1);
		session3.invalidate().block();

		// Request 2 saves session after invalidated
		session2.save().block();

		// Session should not be present
		WebSession session4 = this.store.retrieveSession(id).block();
		assertThat(session4).isNull();
	}

	@Test
	public void expirationCheckPeriod() {

		DirectFieldAccessor accessor = new DirectFieldAccessor(this.store);
		Map<?,?> sessions = (Map<?, ?>) accessor.getPropertyValue("sessions");
		assertThat(sessions).isNotNull();

		// Create 100 sessions
		IntStream.range(0, 100).forEach(i -> insertSession());
		assertThat(sessions.size()).isEqualTo(100);

		// Force a new clock (31 min later), don't use setter which would clean expired sessions
		accessor.setPropertyValue("clock", Clock.offset(this.store.getClock(), Duration.ofMinutes(31)));
		assertThat(sessions.size()).isEqualTo(100);

		// Create 1 more which forces a time-based check (clock moved forward)
		insertSession();
		assertThat(sessions.size()).isEqualTo(1);
	}

	@Test
	public void maxSessions() {

		IntStream.range(0, 10000).forEach(i -> insertSession());
		assertThatIllegalStateException().isThrownBy(
				this::insertSession)
			.withMessage("Max sessions limit reached: 10000");
	}

	private WebSession insertSession() {
		WebSession session = this.store.createWebSession().block();
		assertThat(session).isNotNull();
		session.start();
		session.save().block();
		return session;
	}

	// CVE-2026-41839: 验证 changeSessionId() 正确更换 ID
	@Test
	public void changeSessionIdUpdatesSessionMap() {
		WebSession session = insertSession();
		String oldId = session.getId();

		session.changeSessionId().block();

		String newId = session.getId();
		// 新旧 ID 不同
		assertThat(newId).isNotEqualTo(oldId);
		// 通过旧 ID 无法检索
		assertThat(this.store.retrieveSession(oldId).block()).isNull();
		// 通过新 ID 可以检索，且是同一 session
		WebSession retrieved = this.store.retrieveSession(newId).block();
		assertThat(retrieved).isNotNull();
		assertThat(retrieved).isSameAs(session);
	}

	// CVE-2026-41839: 验证并发调用 changeSessionId() 不丢失 session
	@Test
	public void changeSessionIdConcurrently() throws Exception {
		WebSession session = insertSession();

		int threadCount = 10;
		ExecutorService executor = Executors.newFixedThreadPool(threadCount);
		CountDownLatch latch = new CountDownLatch(threadCount);

		// 多线程同时调用 changeSessionId
		for (int i = 0; i < threadCount; i++) {
			executor.submit(() -> {
				try {
					session.changeSessionId().block();
				}
				finally {
					latch.countDown();
				}
			});
		}

		assertThat(latch.await(10, TimeUnit.SECONDS)).isTrue();
		executor.shutdown();

		// 所有并发操作完成后，session 必须仍然可以通过当前 ID 检索到
		String finalId = session.getId();
		WebSession retrieved = this.store.retrieveSession(finalId).block();
		assertThat(retrieved).isNotNull();
		assertThat(retrieved).isSameAs(session);

		// sessions map 中只有一个指向该 session 的条目
		Map<String, WebSession> sessions = this.store.getSessions();
		long count = sessions.values().stream().filter(s -> s == session).count();
		assertThat(count).isEqualTo(1);
	}

}
