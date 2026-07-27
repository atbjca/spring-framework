# gav-rebrand Specification

## Purpose

定义 Spring Framework 6.2 NES 对外发布坐标、制品元数据脱敏规则与下游兼容性要求，确保业务只需替换依赖坐标而无需修改 Java package 或 import。

## Requirements

### Requirement: NES GAV 坐标

所有对外发布的 `spring-*` 模块与 `framework-bom` MUST 使用 `cn.bjca.footstone.bpring` group、`bjca-footstone-bpring-*` artifact 前缀及 NES patch 版本。

#### Scenario: spring-core 发布坐标

- **WHEN** 执行 `publishToMavenLocal` 或 `publish` 发布 `spring-core`
- **THEN** SNAPSHOT 坐标为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1-SNAPSHOT`

#### Scenario: BOM 发布坐标

- **WHEN** 发布 `framework-bom`
- **THEN** artifactId 为 `bjca-footstone-bpring-framework-bom`

### Requirement: Java 包兼容性

GAV 重品牌 MUST NOT 修改任何 `org.springframework.*` Java package、类名或 import 路径。

#### Scenario: 下游仅改依赖

- **WHEN** 业务项目切换到 NES 坐标
- **THEN** 业务 Java 源码中的 `import org.springframework.*` 无需修改

### Requirement: manifest 元数据脱敏

每个 `spring-*` 模块 JAR MUST 使用重品牌 Implementation-Title 和 Automatic-Module-Name，并以 `originalVersion` 作为 Implementation-Version。

#### Scenario: SpringVersion 运行时版本

- **WHEN** 应用调用 `SpringVersion.getVersion()`
- **THEN** 返回值 MUST 为 `6.2.19`

### Requirement: POM 元数据脱敏

Maven POM MUST NOT 包含官方 Spring Projects 的 organization、scm 或 developer 信息，并 MUST 指向 BJCA 组织信息。

#### Scenario: POM organization

- **WHEN** 检查任意 `spring-*` 模块生成的 POM
- **THEN** `organization.name` 为 `BJCA`

### Requirement: GAV 映射文档

`doc/GAV_MAPPING.md` MUST 列出全部 24 个 `spring-*` 模块及 `framework-bom` 的原始坐标与 NES 坐标对照表。

#### Scenario: spring-core-test 纳入映射

- **WHEN** 查阅 `doc/GAV_MAPPING.md`
- **THEN** 包含 `spring-core-test` 到 `bjca-footstone-bpring-core-test` 的条目

### Requirement: 与 Boot NES 栈对齐

`projectGroup` 与 `version` 命名 MUST 与 Spring Boot NES 的 `forkGroupIdBase` 和 `nes.patch` 规范一致。

#### Scenario: 属性对照可查

- **WHEN** 阅读 `doc/REQUIREMENTS.md`
- **THEN** 可找到 Framework 与 Boot NES 属性的对照说明
