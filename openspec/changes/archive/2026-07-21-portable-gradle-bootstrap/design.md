## Context

The tracked Wrapper configuration currently points at a user-specific `file://` path. Separately, `setup-gradle-local.sh` scans and installs every Gradle archive it finds, deriving each cache key from that archive's local filesystem URL. Gradle Wrapper keys its cache from the configured `distributionUrl`, so an installed archive is useful only when its distribution name and URL hash both match the Wrapper request.

The solution must work on macOS, Linux, developer workstations, containers, and CI. It must retain the pinned Gradle version, support networkless environments that provide the matching archive, and preserve the existing Java 8/11 toolchain arguments.

## Goals / Non-Goals

**Goals:**

- Keep all tracked Gradle launch configuration free of user- and host-specific absolute paths.
- Use the standard HTTPS Wrapper distribution as the canonical distribution identity.
- Verify the distribution archive against a pinned SHA-256 checksum.
- Prewarm the exact Wrapper cache entry from a matching local archive when available.
- Produce actionable diagnostics for missing or mismatched local archives.
- Expose tests through a conventional `make test` target without changing toolchain selection.

**Non-Goals:**

- Upgrade the project from Gradle 7.6.3 to Gradle 8.x.
- Bundle a Gradle distribution in Git.
- Automatically download arbitrary distributions in the setup script.
- Discover or override `JAVA_HOME` or Gradle Java toolchains.
- Change Spring Framework runtime code or dependency repositories.

## Decisions

### Use the official HTTPS URL as the canonical Wrapper identity

`gradle-wrapper.properties` will reference the version-pinned Gradle 7.6.3 binary distribution on `services.gradle.org` and include `distributionSha256Sum`. This is portable and allows ordinary Wrapper behavior when no local archive is supplied.

Alternative considered: rewrite `distributionUrl` to each machine's local archive. Rejected because it dirties tracked configuration, changes the Wrapper cache key per workstation, and recreates the portability problem.

### Derive the local archive requirement from Wrapper configuration

The setup script will read `distributionUrl` and `distributionSha256Sum` from `gradle/wrapper/gradle-wrapper.properties`, unescape the Java properties URL, and derive the exact archive basename and distribution directory name. It will not infer compatibility from other Gradle archives in the directory.

Alternative considered: continue installing every `gradle-*.zip`. Rejected because unrelated versions can produce a misleading successful setup while the Wrapper remains unusable.

### Use the configured URL when calculating the cache path

When a matching local zip exists, the script will copy and optionally unpack it under `GRADLE_USER_HOME/wrapper/dists/<distribution>/<hash>`, where `<hash>` is Gradle Wrapper's base-36 MD5 representation of the configured HTTPS URL. The source archive's local path will never participate in the cache identity.

### Keep local archive discovery optional and environment-driven

An explicitly non-empty `LOCAL_GRADLE_DIR` takes precedence. Otherwise the script uses `${HOME}/dev` for compatibility with the existing workflow. Both are runtime-derived paths; neither is written into tracked configuration. A missing directory or exact archive is non-fatal so the Wrapper can use its normal HTTPS download behavior.

### Verify before populating the cache

The script will calculate SHA-256 using Python, which is already required for Wrapper hash calculation, and compare it with `distributionSha256Sum`. A mismatch is fatal and must not create the Wrapper success marker.

### Add a Make test target with existing toolchains

`make test` will depend on `setup-gradle` and invoke `./gradlew test -PmainToolchain=8 -PtestToolchain=11`. It will not implicitly run `clean`; callers can request `make clean test` when both operations are desired.

## Risks / Trade-offs

- **The matching local archive is absent in an offline environment** → Print the exact expected filename and configured directory; the subsequent Wrapper failure remains explicit.
- **Gradle changes its cache path algorithm** → This repository remains pinned to the current Wrapper generation; tests will verify the calculated cache location against the configured URL.
- **A corrupted or substituted local archive is supplied** → Reject it before copying or unpacking by enforcing the pinned SHA-256 checksum.
- **Python is unavailable** → The existing setup script already depends on Python; retain that documented prerequisite rather than adding divergent platform-specific checksum tools.
- **`~/dev` is not a preferred archive location** → Allow `LOCAL_GRADLE_DIR` to override it without editing repository files.

## Migration Plan

1. Replace the workstation `file://` Wrapper URL with the official Gradle 7.6.3 HTTPS URL and checksum.
2. Update the setup script to parse that configuration and prewarm only its exact cache entry.
3. Add and verify the `make test` target.
4. Developers with offline requirements place `gradle-7.6.3-bin.zip` in `LOCAL_GRADLE_DIR` or `~/dev`; online users require no local setup.
5. Rollback consists of reverting the three build-system files; no generated application data or API migration is involved.

## Open Questions

None.
