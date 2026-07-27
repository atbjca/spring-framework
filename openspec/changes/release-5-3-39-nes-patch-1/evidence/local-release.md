# Local RELEASE Evidence

## Scope and preflight

- Component: `spring-framework-5.3`
- Target: `5.3.39-nes.patch.1`
- Owner lease: held by coordinating session as `wave1-framework-53`
- Preflight: passed at `2026-07-27T03:12:02Z`; no blockers
- Branch: `5.3.x-bjca-patch`
- Starting HEAD: `03d99b8b625ca3400b5f0055949ac5dacd88098a`
- Origin fetch/push: `https://github.com/atbjca/spring-framework.git`
- Active OpenSpec change: `release-5-3-39-nes-patch-1` only
- Initial tracked changes: none
- Initial untracked changes: this OpenSpec change only
- Ignored/local tool directories: none present; any such directories remain excluded from staging
- Current version at freeze: `5.3.39-nes.patch.1-SNAPSHOT`
- Target version: `5.3.39-nes.patch.1`
- Declared internal upstreams: none
- Approved publication exclusions: none

## Toolchain

- Gradle: `7.6.3`
- Runtime JVM: Amazon Corretto `17.0.17`
- Main compilation toolchain: JDK 8
- Test toolchain: JDK 11
- OpenSpec CLI: available and change apply-ready (`spec-driven`)

## Local gates

No credential values or raw user-level configuration are stored here.

| Gate | Command | Result |
| --- | --- | --- |
| Build | Fresh `make build` waived by user | PASS by approved composite ancestor evidence |
| Tests | Fresh `make test` waived by user | PASS by approved composite ancestor evidence |
| Local publication | `GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.workers.max=3' make install` | PASS, exit 0, `BUILD SUCCESSFUL in 45s` |
| Generated POM scan | `find ... -exec sh -c '... xmllint ...' sh {} +` | PASS, 24 valid POMs, 0 internal SNAPSHOT matches |
| Local consumer | `mvn -o -q -f /tmp/nes-fw53-release-consumer/pom.xml package` | PASS, exit 0 |

An earlier build invocation began with `-PmainToolchain=8 -PtestToolchain=11`,
but its execution channel returned before the Gradle child process exited. A
later test rerun was explicitly interrupted with exit 130 when the coordinator
revoked the global build slot. Neither invocation is accepted as final gate
evidence. No install, POM scan, or consumer smoke was started until the
coordinator later granted the exclusive localPublish slot. No deploy, tag, or
push was performed.

## Development-evidence reuse audit

Audit performed without starting Make, Gradle, or Maven. All commits below are
confirmed ancestors of starting HEAD
`03d99b8b625ca3400b5f0055949ac5dacd88098a`.

| Evidence commit | Existing evidence | Reuse decision |
| --- | --- | --- |
| `edcc1522c25f53fe49f1294bc2859ce09368d66a` | Full `make build` passed after repository-wide checkstyle remediation | Reusable as the base full-build evidence in the approved composite |
| `104f865e9575679c7a41463411300301cc12c5c9` | WebFlux CVE targeted tests and `make build-thin` passed | Reusable as development regression evidence only |
| `e3995af772821cbc252f41170382f1329d6dedb7` | JDK 8 main compile, JDK 11 test compile, JDK 8 runtime checks, and `make build-thin` passed | Reusable as toolchain and main-source compilation evidence only |
| `03d99b8b625ca3400b5f0055949ac5dacd88098a` | Portable Wrapper setup plus the `make test` entry point was statically/conditionally verified | Reusable only for entry-point and wrapper readiness; it does not record an unambiguous full test result |

Intermediate-diff findings:

- Main sources are identical between `e3995af772821cbc252f41170382f1329d6dedb7`
  and starting HEAD.
- The targeted CVE test files from `104f865e9575679c7a41463411300301cc12c5c9`
  are unchanged at starting HEAD.
- Commit `3c517d33133bf6a08d04805ec16731470fd6da0a` subsequently removed three
  obsolete assertions from two resource-handler tests.
- Later commits changed `Makefile`, Wrapper bootstrap configuration, and the
  setup script. They did not change main sources, but they changed the exact
  release command entry points being accepted now.
- The current release worktree changes no source or test file; it changes the
  version from `5.3.39-nes.patch.1-SNAPSHOT` to `5.3.39-nes.patch.1` plus
  release documentation and OpenSpec evidence.

The user explicitly authorized this component to reuse the composite ancestry
evidence and not re-run `make build` or `make test`. The composite covers the
earlier full build, targeted tests for subsequent production changes, and the
later all-module main compilation under the final JDK 8/11 toolchain. The
intervening changes are limited to the recorded test assertion deletion and
build/bootstrap entry points, and the current release worktree changes no
source or test input.

This explicit exception satisfies release tasks 3.1 and 3.2 only. RELEASE
publication metadata and consumer behavior were established separately by the
fresh serialized gates below.

## Local publication

- Completed: `2026-07-27T04:55:35Z`
- Exact command:
  `GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.workers.max=3' make install`
- Expanded task: `./gradlew clean publishToMavenLocal -PmainToolchain=8
  -PtestToolchain=11` with the Makefile's documented test, checkstyle, API, and
  documentation exclusions
- Resource override: Gradle JVM maximum 4 GiB; maximum 3 workers
- Result: exit 0; `BUILD SUCCESSFUL in 45s`
- Task summary: 240 actionable; 180 executed, 34 from cache, 26 up-to-date
- Non-blocking diagnostics: legacy JAXB POM `tools.jar` warnings, Kotlin
  `jdkHome` deprecation, and remote build-cache 403 followed by local fallback

## Publication set

The generated and Maven-local inventories both contain these 24 publications,
all under `cn.bjca.footstone.bpring:5.3.39-nes.patch.1`:

```text
bjca-footstone-bpring
bjca-footstone-bpring-aop
bjca-footstone-bpring-aspects
bjca-footstone-bpring-beans
bjca-footstone-bpring-context
bjca-footstone-bpring-context-indexer
bjca-footstone-bpring-context-support
bjca-footstone-bpring-core
bjca-footstone-bpring-expression
bjca-footstone-bpring-framework-bom
bjca-footstone-bpring-instrument
bjca-footstone-bpring-jcl
bjca-footstone-bpring-jdbc
bjca-footstone-bpring-jms
bjca-footstone-bpring-messaging
bjca-footstone-bpring-orm
bjca-footstone-bpring-oxm
bjca-footstone-bpring-r2dbc
bjca-footstone-bpring-test
bjca-footstone-bpring-tx
bjca-footstone-bpring-web
bjca-footstone-bpring-webflux
bjca-footstone-bpring-webmvc
bjca-footstone-bpring-websocket
```

This reconciles the representative core GAV. The local repository contains 24
POMs, 23 Gradle module metadata files, 66 jars (main, sources, and javadoc for
22 code modules), and 3 root distribution zip artifacts. There are no approved
publication exclusions; `integration-tests` has no Maven publication and is
not part of the publication set.

## Generated metadata scan

- Parser: `xmllint`, applied to every generated
  `build/publications/*/pom-default.xml`
- Result: `POM_COUNT=24 INVALID_XML=0 POMS_WITH_INTERNAL_REFS=19
  POMS_WITH_INTERNAL_SNAPSHOT=0`
- Internal selection covered dependency, parent, and plugin nodes whose
  `groupId` starts with `cn.bjca.footstone`
- Result: PASS; every internal dependency in generated metadata is RELEASE-only

## Local-only consumer

- Completed: `2026-07-27T05:01:04Z`
- Temporary project: `/tmp/nes-fw53-release-consumer` (not staged)
- Dependency:
  `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:5.3.39-nes.patch.1`
- Command: `mvn -o -q -f /tmp/nes-fw53-release-consumer/pom.xml package`
- Result: exit 0; offline dependency resolution and compilation succeeded
- Network repositories: none declared; Maven offline mode enforced local-only
  resolution
