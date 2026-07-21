## ADDED Requirements

### Requirement: Wrapper distribution configuration is portable and integrity checked
The repository SHALL configure Gradle Wrapper with a version-pinned HTTPS distribution URL and its SHA-256 checksum, and MUST NOT reference an absolute path tied to a user or workstation.

#### Scenario: Wrapper configuration is used on another operating system
- **WHEN** the repository is checked out under a different home directory or operating system
- **THEN** the Wrapper distribution configuration remains valid without editing a tracked file

#### Scenario: Wrapper obtains a distribution archive
- **WHEN** Gradle Wrapper installs the configured distribution
- **THEN** it verifies the archive against the pinned `distributionSha256Sum`

### Requirement: Local bootstrap matches the configured Wrapper distribution exactly
The local setup command SHALL derive the required archive filename from `gradle-wrapper.properties` and MUST populate the cache only from an archive with that exact filename.

#### Scenario: Matching local archive is available
- **WHEN** the configured local archive directory contains the exact Wrapper archive filename
- **THEN** the setup command installs that archive into the cache entry requested by the configured Wrapper URL

#### Scenario: Only another Gradle version is available
- **WHEN** the local archive directory contains Gradle archives but not the exact Wrapper archive filename
- **THEN** the setup command reports the expected filename and does not treat another version as satisfying the Wrapper

### Requirement: Local cache uses the canonical Wrapper URL identity
The setup command MUST calculate the Wrapper cache key from the configured `distributionUrl`, not from the local archive filesystem path.

#### Scenario: Identical archive is stored under different home directories
- **WHEN** two machines provide the matching archive from different local filesystem paths
- **THEN** both setup commands populate the cache key corresponding to the same configured HTTPS URL

### Requirement: Local archive integrity is enforced
The setup command MUST verify a matching local archive against the configured SHA-256 checksum before marking the Wrapper distribution ready.

#### Scenario: Local archive checksum matches
- **WHEN** the matching local archive has the configured SHA-256 checksum
- **THEN** the setup command may copy, unpack, and mark the distribution ready

#### Scenario: Local archive checksum differs
- **WHEN** the matching local archive does not have the configured SHA-256 checksum
- **THEN** the setup command fails and does not create a successful installation marker

### Requirement: Local bootstrap remains optional
The setup command SHALL allow `LOCAL_GRADLE_DIR` and `GRADLE_USER_HOME` overrides and SHALL fall back to runtime-derived home locations without storing those paths in tracked configuration.

#### Scenario: Explicit local directory is supplied
- **WHEN** the caller sets `LOCAL_GRADLE_DIR` to a non-empty directory
- **THEN** the setup command searches that directory for the exact required archive

#### Scenario: No matching local archive exists
- **WHEN** the setup command cannot find the exact required archive
- **THEN** it exits successfully after explaining that Gradle Wrapper will use its configured HTTPS download behavior

### Requirement: Make exposes a toolchain-aware test entry point
The Makefile SHALL provide a `test` target that prepares the optional Gradle cache and invokes the Gradle `test` task with the existing main and test Java toolchain properties.

#### Scenario: Test target is rendered
- **WHEN** `make -n test` is executed
- **THEN** the rendered Gradle command includes `test`, `-PmainToolchain=8`, and `-PtestToolchain=11`

#### Scenario: Clean and test are requested together
- **WHEN** `make clean test` is executed in an environment with the required Java toolchains and Gradle distribution access
- **THEN** Make runs both targets without reporting that `test` has no rule
