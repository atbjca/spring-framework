## ADDED Requirements

### Requirement: Make targets must not force a machine-specific JAVA_HOME
The Make build entry points MUST NOT assign `JAVA_HOME` to an absolute path tied to a particular user, operating system, SDKMAN installation, or workstation before invoking Gradle Wrapper.

#### Scenario: Build recipe is portable across user directories
- **WHEN** the Makefile is inspected after the change
- **THEN** the `clean`, `build`, `build-thin`, `install`, `deploy`, `docs`, and `checkstyle` recipes contain no `/Users/anan/.sdkman/candidates/java/11.0.30-tem` assignment

### Requirement: Gradle Wrapper must select the launcher Java from the caller environment
The Make build entry points SHALL invoke `./gradlew` without overriding `JAVA_HOME`, allowing Gradle Wrapper to use a valid caller-provided `JAVA_HOME` or the `java` executable available on `PATH` when `JAVA_HOME` is unset.

#### Scenario: Caller provides a valid JAVA_HOME
- **WHEN** a supported Make target is invoked with a valid `JAVA_HOME`
- **THEN** the Gradle Wrapper invocation inherits that `JAVA_HOME` unchanged

#### Scenario: Caller leaves JAVA_HOME unset
- **WHEN** a supported Make target is invoked without `JAVA_HOME` and `java` is available on `PATH`
- **THEN** the Gradle Wrapper is allowed to launch using the `PATH` Java without a Makefile-injected fallback path

### Requirement: Existing Gradle task and toolchain behavior must be preserved
Removing the hardcoded Java launcher path MUST NOT change the Gradle tasks, task exclusions, target prerequisites, or the existing `-PmainToolchain=8 -PtestToolchain=11` arguments used by compilation and publication targets.

#### Scenario: Compilation target is rendered after the change
- **WHEN** `make -n build` or an equivalent dry-run renders the build recipe
- **THEN** it still invokes `./gradlew build` with `-PmainToolchain=8 -PtestToolchain=11` and retains the existing prerequisites

#### Scenario: Non-compilation target is rendered after the change
- **WHEN** `make -n clean`, `make -n docs`, or `make -n checkstyle` renders its recipe
- **THEN** the Gradle task names and existing task arguments are unchanged except for removal of the `JAVA_HOME` assignment
