## 1. Portable Wrapper Configuration

- [x] 1.1 Replace the workstation-specific Wrapper distribution URL with the official Gradle 7.6.3 HTTPS binary distribution URL.
- [x] 1.2 Pin the official Gradle 7.6.3 binary distribution SHA-256 checksum and verify tracked build configuration contains no user-specific absolute path.

## 2. Exact Local Distribution Bootstrap

- [x] 2.1 Parse the configured distribution URL and checksum from `gradle-wrapper.properties`, including Java-properties URL escaping.
- [x] 2.2 Select only the exact configured archive from `LOCAL_GRADLE_DIR` or the runtime-derived default directory.
- [x] 2.3 Calculate the cache key from the configured Wrapper URL, verify SHA-256 before installation, and preserve idempotent copy/unpack behavior.
- [x] 2.4 Emit accurate diagnostics for matching, mismatched, missing, corrupt, and already-installed distributions while preserving online Wrapper fallback.

## 3. Make Entry Points

- [x] 3.1 Add `test` to the Makefile targets and help output, invoking the existing Java 8/11 toolchain properties.
- [x] 3.2 Update Gradle setup documentation in the Makefile and script so it describes exact-version cache prewarming and HTTPS fallback accurately.

## 4. Verification

- [x] 4.1 Validate OpenSpec artifacts and shell syntax, and verify `make -n test` renders the required Gradle task and toolchain arguments.
- [x] 4.2 Exercise setup behavior for a missing exact archive, a mismatched available version, checksum rejection, and a valid matching archive in an isolated temporary cache.
- [x] 4.3 Run `make clean test` or the closest environment-supported Gradle verification, documenting any external Java toolchain or network limitation.
- [x] 4.4 Re-scan tracked build configuration for machine-specific absolute paths and review the final diff against the specification.
