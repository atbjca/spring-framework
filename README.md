# <img src="framework-docs/src/docs/spring-framework.png" width="80" height="80"> Spring Framework [![Build Status](https://github.com/spring-projects/spring-framework/actions/workflows/build-and-deploy-snapshot.yml/badge.svg?branch=main)](https://github.com/spring-projects/spring-framework/actions/workflows/build-and-deploy-snapshot.yml?query=branch%3Amain) [![Revved up by Develocity](https://img.shields.io/badge/Revved%20up%20by-Develocity-06A0CE?logo=Gradle&labelColor=02303A)](https://ge.spring.io/scans?search.rootProjectNames=spring)

This is the home of the Spring Framework: the foundation for all [Spring projects](https://spring.io/projects). Collectively the Spring Framework and the family of Spring projects are often referred to simply as "Spring". 

Spring provides everything required beyond the Java programming language for creating enterprise applications for a wide range of scenarios and architectures. Please read the [Overview](https://docs.spring.io/spring-framework/reference/overview.html) section of the reference documentation for a more complete introduction.

## Code of Conduct

This project is governed by the [Spring Code of Conduct](https://github.com/spring-projects/spring-framework/?tab=coc-ov-file#contributor-code-of-conduct). By participating, you are expected to uphold this code of conduct. Please report unacceptable behavior to spring-code-of-conduct@spring.io.

## Access to Binaries

For access to artifacts or a distribution zip, see the [Spring Framework Artifacts](https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-Artifacts) wiki page.

## Documentation

The Spring Framework maintains reference documentation ([published](https://docs.spring.io/spring-framework/reference/) and [source](framework-docs/modules/ROOT)), GitHub [wiki pages](https://github.com/spring-projects/spring-framework/wiki), and an
[API reference](https://docs.spring.io/spring-framework/docs/current/javadoc-api/). There are also [guides and tutorials](https://spring.io/guides) across Spring projects.

## Micro-Benchmarks

See the [Micro-Benchmarks](https://github.com/spring-projects/spring-framework/wiki/Micro-Benchmarks) wiki page.

## Build from Source

See the [Build from Source](https://github.com/spring-projects/spring-framework/wiki/Build-from-Source) wiki page and the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## 本地维护（bjca-patch / NES 6.2）

- 当前 RELEASE：`6.2.19-nes.patch.1`
- BOM：`cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1`
- 代表制品：`cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1`
- 完整发布集：23 个 `bjca-footstone-bpring-*` 模块、BOM，以及 `spring:framework-api`、`spring:framework-docs`，共 26 个 GAV
- 内部前置 RELEASE：无；发布排除项：无
- 本地发布门禁：复用可审计的开发构建/测试证据；现场执行 `make install`、生成 POM 扫描及最小本地消费者验证
- Nexus 仓库：用户级 `nexusReleaseUrl` 配置指向的 RELEASE 仓库；凭证仅保存在 `~/.gradle/gradle.properties`
- 约束：`Implementation-Version` 保持上游基线 `6.2.19`；Nexus RELEASE 不可覆盖或重复发布
- [OpenSpec: 6.2 NES GAV 重品牌](openspec/changes/archive/2026-07-27-6.2-nes-gav-rebrand/proposal.md)
- [OpenSpec: 6.2 CVE 评估](openspec/changes/archive/2026-07-27-6.2-cve-assessment/proposal.md)
- [业务需求](doc/REQUIREMENTS.md)
- [GAV 映射表](doc/GAV_MAPPING.md)
- [漏洞总览](doc/VULNERABILITY_FIXES.md)
- [Nexus 发布](doc/NEXUS_DEPLOY.md)
- [快速入门](doc/QUICK_START.md)
- [测试指南](doc/TESTING.md)

## Continuous Integration Builds

CI builds are defined with [GitHub Actions workflows](.github/workflows).

## Stay in Touch

Follow [@SpringCentral](https://twitter.com/springcentral), [@SpringFramework](https://twitter.com/springframework), and its [team members](https://twitter.com/springframework/lists/team/members) on 𝕏. In-depth articles can be found at [The Spring Blog](https://spring.io/blog/), and releases are announced via our [releases feed](https://spring.io/blog/category/releases).

## License

The Spring Framework is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
