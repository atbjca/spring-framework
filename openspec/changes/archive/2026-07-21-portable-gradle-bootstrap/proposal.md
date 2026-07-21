## Why

The Gradle Wrapper currently references a workstation-specific `file:///Users/anan/...` distribution, so builds fail on Linux, CI, and any machine without that exact path. The local distribution setup also installs every discovered Gradle archive without ensuring it matches the Wrapper configuration, which can report success while leaving the requested distribution unavailable.

## What Changes

- Restore a repository-portable, version-pinned HTTPS Gradle Wrapper distribution with integrity verification.
- Make the local Gradle bootstrap derive the required archive from `gradle-wrapper.properties` and install only an exact match.
- Populate the Wrapper cache using the configured distribution URL identity so local/offline and normal online startup resolve the same cache entry.
- Keep the local archive directory configurable without writing machine-specific paths into tracked files, with a predictable portable search order.
- Provide clear diagnostics when the required local archive is absent or mismatched, while allowing the Wrapper to download from its configured HTTPS URL when networking is available.
- Add a first-class `make test` entry point using the project's existing Java toolchain configuration.

## Capabilities

### New Capabilities

- `portable-gradle-bootstrap`: Defines portable, integrity-checked Gradle Wrapper distribution resolution, optional exact-version local cache prewarming, and consistent Make test invocation across developer machines and CI.

### Modified Capabilities

None.

## Impact

- Affected files: `gradle/wrapper/gradle-wrapper.properties`, `scripts/setup-gradle-local.sh`, and `Makefile`.
- Developer environments may optionally retain a matching Gradle zip locally; unrelated Gradle versions will no longer be installed or treated as satisfying the Wrapper.
- Machines with network access can use the standard Wrapper download path without local configuration.
- No Spring Framework runtime API or production behavior changes.
