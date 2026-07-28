# Local RELEASE Verification Evidence

## Scope and ownership

- Component: `spring-framework-6.2`
- Change: `release-6-2-19-nes-patch-1`
- Target: `6.2.19-nes.patch.1`
- Initial HEAD: `97061022071589bd05c67edf320a2978b69353f9`
- Branch: `6.2.x-bjca-patch`
- Manifest lease owner: `wave1-framework-62`
- Lease acquired: `2026-07-27T03:08:51Z`
- Lease expiry: `2026-07-27T09:08:51Z`
- Baseline recorded: `2026-07-27T03:12:31Z`
- Active OpenSpec changes: only `release-6-2-19-nes-patch-1`
- Declared upstream components: none
- Approved publication exclusions: none

## Repository and toolchain

- `origin` fetch/push: `https://github.com/atbjca/spring-framework.git`
- `gitlab` fetch/push: `git@192.168.131.1:NES/spring-framework.git`
- Initial version: `6.2.19-nes.patch.1-SNAPSHOT`
- Java: Amazon Corretto `17.0.17`
- Gradle: `8.14.5`
- OS: macOS x86_64
- Initial tracked changes: none
- Initial untracked release files: this OpenSpec change only
- Excluded local tool paths: `.claude/`, `.codex/`

No credential values were read or recorded. User-level Gradle configuration remains outside the repository.

## Commands and results

### Reused build and test evidence

The coordinator approved reuse of the existing archived build and test evidence instead of running another full build/test cycle for this metadata-only RELEASE preparation.

- Evidence commit: `1710d7342fd1b5247f26bfafd84f2ce7c77aa6b9` (`feat: NES GAV rebrand for Spring Framework 6.2.19`, 2026-06-26T16:50:03+08:00).
- Evidence path: `openspec/changes/archive/2026-07-27-6.2-nes-gav-rebrand/tasks.md`.
- Recorded results: `make build-thin` passed; `make test` full regression passed after the documented `spring-webflux` flaky retry.
- Supporting environment record: `doc/TESTING.md` records Corretto 17, `make test` `BUILD SUCCESSFUL`, 219 tasks, no failures.
- Targeted regression evidence commit: `b7b1734a013eda8cf7f312dec6cde58fe3ffc139`.
- Targeted evidence path: `openspec/changes/archive/2026-07-27-6.2-cve-verification-closeout/tasks.md`.
- Targeted results: webmvc/webflux `ContentBasedVersionStrategyTests`, core `ResourceTests`, and websocket `StompSubProtocolHandlerTests` all recorded `BUILD SUCCESSFUL`.
- Archive/reconciliation commit: `97061022071589bd05c67edf320a2978b69353f9`.

Ancestry and intervening-diff audit:

- `git merge-base --is-ancestor 1710d7342f HEAD` returned exit `0`.
- `git merge-base --is-ancestor b7b1734a01 HEAD` returned exit `0`.
- `git diff --name-only 1710d7342f..HEAD -- '*/src/**' '*.java' '*.kt' '*.groovy'` returned no paths.
- Intervening build-file changes are limited to the Gradle 8.14.3 to 8.14.5 wrapper update, wrapper setup/Make launch plumbing, and Nexus publication repository configuration. They do not change application or test sources or the underlying `clean build -x test` / `test` task semantics.
- The current RELEASE working diff changes only `gradle.properties` from `6.2.19-nes.patch.1-SNAPSHOT` to `6.2.19-nes.patch.1`, the three required release documents, and this OpenSpec change. It contains no source or build-logic change.

Conclusion: the archived `make build-thin` and full `make test` results are reusable for tasks 3.1 and 3.2. Publication metadata remained version-sensitive, so fresh `make install`, generated-POM scanning, and local consumer validation were completed below.

### Interrupted attempts before reuse was approved

- `make build-thin` exited `2` before Gradle execution because `scripts/setup-gradle-local.sh` encountered an unrelated corrupt `~/dev/gradle-7.6.4-bin.zip` while scanning all local distributions.
- Retry with `LOCAL_GRADLE_DIR=/tmp/nes-gradle-ready-only make build-thin` reached compilation but was externally terminated with exit `143`.
- A subsequent retry also reached compilation and was externally terminated with exit `143`.
- The final in-progress retry was stopped immediately on coordinator instruction and exited `130`.

No interrupted attempt is treated as passing evidence. At `2026-07-27T04:07:21Z`, no make, Gradle, or Maven process for this component is running, and no further such command will start before coordinator authorization.

## Publication set

Authorized command:

```bash
GRADLE_OPTS='-Xmx4g -Dorg.gradle.workers.max=3' LOCAL_GRADLE_DIR=/tmp/nes-gradle-ready-only make install
```

- Result: exit `0`, `BUILD SUCCESSFUL in 26m 16s`.
- Tasks: 255 actionable; 212 executed, 37 from cache, 6 up-to-date.
- Completed before the scan timestamp `2026-07-27T05:29:01Z`.
- Remote build cache HTTP 403 caused Gradle to disable that cache and continue locally; it did not fail publication.
- Maven Local contains 26 target-version POMs and their applicable JAR, sources, javadoc, Gradle module, docs ZIP, and schema ZIP assets.

Complete GAV set:

- `cn.bjca.footstone.bpring:bjca-footstone-bpring-{aop,aspects,beans,context,context-indexer,context-support,core,core-test,expression,instrument,jcl,jdbc,jms,messaging,orm,oxm,r2dbc,test,tx,web,webflux,webmvc,websocket}:6.2.19-nes.patch.1`
- `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1`
- `spring:framework-api:6.2.19-nes.patch.1`
- `spring:framework-docs:6.2.19-nes.patch.1`

The representative core GAV and BOM are present. There are no approved exclusions, so all 26 publications remain included.

## Generated POM scan

All 26 Gradle-generated `*/build/publications/mavenJava/pom-default.xml` files and all 26 target-version Maven Local POMs passed `xmllint --noout`.

The structured XPath scan counted internal SNAPSHOT dependency, parent, and plugin references with:

```text
count(//*[local-name()='dependency' or local-name()='parent' or local-name()='plugin'][*[local-name()='groupId' and starts-with(normalize-space(.), 'cn.bjca.footstone')]][*[local-name()='version' and contains(normalize-space(.), '-SNAPSHOT')]])
```

Results at `2026-07-27T05:29:01Z`:

- Generated POM count: 26; internal SNAPSHOT references: 0; exit `0`.
- Maven Local POM count: 26; internal SNAPSHOT references: 0; exit `0`.
- With no exclusions, excluded-module reference count is vacuously 0.

## Representative consumer

Temporary consumer: `/tmp/spring-framework-6.2-release-consumer`; repositories were restricted to `mavenLocal()` and network use was disabled with `--offline`.

```bash
GRADLE_OPTS='-Xmx1g -Dorg.gradle.workers.max=1' ./gradlew -p /tmp/spring-framework-6.2-release-consumer --offline --no-daemon --max-workers=1 verifyRelease
```

- First run: exit `1` in 9 seconds after successfully resolving the correct core and jcl GAVs; the temporary harness compared Groovy `GString` values with `String.contains`, causing a false assertion failure.
- Harness-only correction: convert the generated GAV strings with `.toString()`; no repository file or publication changed.
- Corrected rerun: exit `0`, `BUILD SUCCESSFUL in 10s`, completed before `2026-07-27T05:38:12Z`.
- Resolved: `cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1` and transitive `cn.bjca.footstone.bpring:bjca-footstone-bpring-jcl:6.2.19-nes.patch.1`.
- BOM supplied the omitted core version, proving BOM constraint consumption.
- Internal resolved SNAPSHOTs: 0.
- Runtime result: `SpringVersion=6.2.19`.
