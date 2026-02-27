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

package org.springframework.util;

import org.springframework.lang.Nullable;

/**
 * Utility methods for simple pattern matching, in particular for
 * Spring's typical "xxx*", "*xxx" and "*xxx*" pattern styles.
 *
 * @author Juergen Hoeller
 * @since 2.0
 */
public abstract class PatternMatchUtils {

	/**
	 * Match a String against the given pattern, supporting the following simple
	 * pattern styles: "xxx*", "*xxx", "*xxx*" and "xxx*yyy" matches (with an
	 * arbitrary number of pattern parts), as well as direct equality.
	 * @param pattern the pattern to match against
	 * @param str the String to match
	 * @return whether the String matches the given pattern
	 */
	public static boolean simpleMatch(@Nullable String pattern, @Nullable String str) {
		return simpleMatch(pattern, str, false);
	}

	/**
	 * Match a String against the given pattern, supporting the following simple
	 * pattern styles: "xxx*", "*xxx", "*xxx*" and "xxx*yyy" matches (with an
	 * arbitrary number of pattern parts), as well as direct equality.
	 * @param pattern the pattern to match against
	 * @param str the String to match
	 * @return whether the String matches the given pattern
	 * @since 5.3.43
	 */
	public static boolean simpleMatchIgnoreCase(@Nullable String pattern, @Nullable String str) {
		return simpleMatch(pattern, str, true);
	}

	private static boolean simpleMatch(@Nullable String pattern, @Nullable String str, boolean ignoreCase) {
		if (pattern == null || str == null) {
			return false;
		}

		int firstIndex = pattern.indexOf('*');
		if (firstIndex == -1) {
			return (ignoreCase ? pattern.equalsIgnoreCase(str) : pattern.equals(str));
		}

		if (firstIndex == 0) {
			if (pattern.length() == 1) {
				return true;
			}
			int nextIndex = pattern.indexOf('*', 1);
			if (nextIndex == -1) {
				String suffix = pattern.substring(1);
				return (ignoreCase ? StringUtils.endsWithIgnoreCase(str, suffix) : str.endsWith(suffix));
			}
			String part = pattern.substring(1, nextIndex);
			if (part.isEmpty()) {
				return simpleMatch(pattern.substring(nextIndex), str, ignoreCase);
			}
			int partIndex = indexOf(str, part, 0, ignoreCase);
			while (partIndex != -1) {
				if (simpleMatch(pattern.substring(nextIndex), str.substring(partIndex + part.length()), ignoreCase)) {
					return true;
				}
				partIndex = indexOf(str, part, partIndex + 1, ignoreCase);
			}
			return false;
		}

		return (str.length() >= firstIndex &&
				(ignoreCase ? str.regionMatches(true, 0, pattern, 0, firstIndex) :
						pattern.startsWith(str.substring(0, firstIndex))) &&
				simpleMatch(pattern.substring(firstIndex), str.substring(firstIndex), ignoreCase));
	}

	private static int indexOf(String str, String part, int startIndex, boolean ignoreCase) {
		if (!ignoreCase) {
			return str.indexOf(part, startIndex);
		}
		int limit = str.length() - part.length();
		for (int i = startIndex; i <= limit; i++) {
			if (str.regionMatches(true, i, part, 0, part.length())) {
				return i;
			}
		}
		return -1;
	}

	/**
	 * Match a String against the given patterns, supporting the following simple
	 * pattern styles: "xxx*", "*xxx", "*xxx*" and "xxx*yyy" matches (with an
	 * arbitrary number of pattern parts), as well as direct equality.
	 * @param patterns the patterns to match against
	 * @param str the String to match
	 * @return whether the String matches any of the given patterns
	 */
	public static boolean simpleMatch(@Nullable String[] patterns, String str) {
		if (patterns != null) {
			for (String pattern : patterns) {
				if (simpleMatch(pattern, str)) {
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * Match a String against the given patterns, supporting the following simple
	 * pattern styles: "xxx*", "*xxx", "*xxx*" and "xxx*yyy" matches (with an
	 * arbitrary number of pattern parts), as well as direct equality.
	 * @param patterns the patterns to match against
	 * @param str the String to match
	 * @return whether the String matches any of the given patterns
	 * @since 5.3.43
	 */
	public static boolean simpleMatchIgnoreCase(@Nullable String[] patterns, String str) {
		if (patterns != null) {
			for (String pattern : patterns) {
				if (simpleMatchIgnoreCase(pattern, str)) {
					return true;
				}
			}
		}
		return false;
	}

}
