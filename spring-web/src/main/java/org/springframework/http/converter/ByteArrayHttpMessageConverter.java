/*
 * Copyright 2002-2019 the original author or authors.
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

package org.springframework.http.converter;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.springframework.http.HttpInputMessage;
import org.springframework.http.HttpOutputMessage;
import org.springframework.http.MediaType;
import org.springframework.lang.Nullable;
import org.springframework.util.StreamUtils;

/**
 * Implementation of {@link HttpMessageConverter} that can read and write byte
 * arrays.
 *
 * <p>
 * By default, this converter supports all media types
 * (<code>&#42;/&#42;</code>), and
 * writes with a {@code Content-Type} of {@code application/octet-stream}. This
 * can be
 * overridden by setting the {@link #setSupportedMediaTypes supportedMediaTypes}
 * property.
 *
 * @author Arjen Poutsma
 * @author Juergen Hoeller
 * @since 3.0
 */
public class ByteArrayHttpMessageConverter extends AbstractHttpMessageConverter<byte[]> {

	/**
	 * Create a new instance of the {@code ByteArrayHttpMessageConverter}.
	 */
	public ByteArrayHttpMessageConverter() {
		super(MediaType.APPLICATION_OCTET_STREAM, MediaType.ALL);
	}

	private int maxInMemorySize = -1;

	/**
	 * Set the maximum number of bytes that can be read into memory.
	 * <p>
	 * By default this is set to -1, which means no limit.
	 * 
	 * @since 5.3.42
	 */
	public void setMaxInMemorySize(int maxInMemorySize) {
		this.maxInMemorySize = maxInMemorySize;
	}

	/**
	 * Return the maximum number of bytes that can be read into memory.
	 * 
	 * @since 5.3.42
	 */
	public int getMaxInMemorySize() {
		return this.maxInMemorySize;
	}

	@Override
	public boolean supports(Class<?> clazz) {
		return byte[].class == clazz;
	}

	@Override
	public byte[] readInternal(Class<? extends byte[]> clazz, HttpInputMessage inputMessage) throws IOException {
		long contentLength = inputMessage.getHeaders().getContentLength();
		if (contentLength >= 0 && this.maxInMemorySize >= 0 && contentLength > this.maxInMemorySize) {
			throw new IOException(
					"Content-Length exceeds the configured maximum of " + this.maxInMemorySize + " bytes");
		}
		ByteArrayOutputStream bos = (contentLength >= 0 ? new ByteArrayOutputStream((int) contentLength)
				: new ByteArrayOutputStream());
		InputStream in = inputMessage.getBody();
		byte[] buffer = new byte[StreamUtils.BUFFER_SIZE];
		int bytesRead;
		while ((bytesRead = in.read(buffer)) != -1) {
			bos.write(buffer, 0, bytesRead);
			if (this.maxInMemorySize >= 0 && bos.size() > this.maxInMemorySize) {
				throw new IOException("Memory limit exceeded: " + this.maxInMemorySize + " bytes");
			}
		}
		return bos.toByteArray();
	}

	@Override
	protected Long getContentLength(byte[] bytes, @Nullable MediaType contentType) {
		return (long) bytes.length;
	}

	@Override
	protected void writeInternal(byte[] bytes, HttpOutputMessage outputMessage) throws IOException {
		StreamUtils.copy(bytes, outputMessage.getBody());
	}

}
