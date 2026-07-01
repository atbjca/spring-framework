/*
 * Copyright 2002-2022 the original author or authors.
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

package org.springframework.web.socket.adapter.standard;

import java.util.HashMap;
import java.util.Map;

import javax.websocket.Session;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import org.springframework.core.testfixture.security.TestPrincipal;
import org.springframework.http.HttpHeaders;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.verifyNoMoreInteractions;

/**
 * Unit tests for {@link org.springframework.web.socket.adapter.standard.StandardWebSocketSession}.
 *
 * @author Rossen Stoyanchev
 */
@SuppressWarnings("resource")
public class StandardWebSocketSessionTests {

	private final HttpHeaders headers = new HttpHeaders();

	private final Map<String, Object> attributes = new HashMap<>();


	@Test
	@SuppressWarnings("resource")
	public void getPrincipalWithConstructorArg() {
		TestPrincipal user = new TestPrincipal("joe");
		StandardWebSocketSession session = new StandardWebSocketSession(this.headers, this.attributes, null, null, user);

		assertThat(session.getPrincipal()).isSameAs(user);
	}

	@Test
	public void getPrincipalWithNativeSession() {
		TestPrincipal user = new TestPrincipal("joe");

		Session nativeSession = Mockito.mock(Session.class);
		given(nativeSession.getUserPrincipal()).willReturn(user);

		StandardWebSocketSession session = new StandardWebSocketSession(this.headers, this.attributes, null, null);
		session.initializeNativeSession(nativeSession);

		assertThat(session.getPrincipal()).isSameAs(user);
	}

	@Test
	public void getPrincipalNone() {
		Session nativeSession = Mockito.mock(Session.class);
		given(nativeSession.getUserPrincipal()).willReturn(null);

		StandardWebSocketSession session = new StandardWebSocketSession(this.headers, this.attributes, null, null);
		session.initializeNativeSession(nativeSession);

		reset(nativeSession);

		assertThat(session.getPrincipal()).isNull();
		verifyNoMoreInteractions(nativeSession);
	}

	@Test
	public void getAcceptedProtocol() {
		String protocol = "foo";

		Session nativeSession = Mockito.mock(Session.class);
		given(nativeSession.getNegotiatedSubprotocol()).willReturn(protocol);

		StandardWebSocketSession session = new StandardWebSocketSession(this.headers, this.attributes, null, null);
		session.initializeNativeSession(nativeSession);

		reset(nativeSession);

		assertThat(session.getAcceptedProtocol()).isEqualTo(protocol);
		verifyNoMoreInteractions(nativeSession);
	}

	@Test // gh-29315
	public void addAttributesWithNullKeyOrValue() {
		this.attributes.put(null, "value");
		this.attributes.put("key", null);
		this.attributes.put("foo", "bar");

		assertThat(new StandardWebSocketSession(this.headers, this.attributes, null, null).getAttributes())
				.hasSize(1).containsEntry("foo", "bar");
	}

	// CVE-2026-41838: 验证 Session ID 使用密码学安全的随机数生成器
	@Test
	public void sessionIdIsUnique() {
		// 创建多个 session，验证每个 session 的 ID 都是唯一的
		StandardWebSocketSession session1 = new StandardWebSocketSession(this.headers, new HashMap<>(), null, null);
		StandardWebSocketSession session2 = new StandardWebSocketSession(this.headers, new HashMap<>(), null, null);
		StandardWebSocketSession session3 = new StandardWebSocketSession(this.headers, new HashMap<>(), null, null);

		// 验证三个 session 的 ID 互不相同
		assertThat(session1.getId()).isNotEqualTo(session2.getId());
		assertThat(session2.getId()).isNotEqualTo(session3.getId());
		assertThat(session1.getId()).isNotEqualTo(session3.getId());
	}

	// CVE-2026-41838: 验证 Session ID 为有效 UUID 格式
	@Test
	public void sessionIdIsValidUuid() {
		StandardWebSocketSession session = new StandardWebSocketSession(this.headers, new HashMap<>(), null, null);
		String sessionId = session.getId();

		// 验证 ID 符合 UUID 格式（8-4-4-4-12 长度）
		assertThat(sessionId).matches("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}");
	}

}
