## ADDED Requirements

### Requirement: NES GAV 坐标

所有对外发布的 `spring-*` 模块与 `framework-bom` MUST 使用以下坐标规则：

- `groupId` = `cn.bjca.footstone.bpring`（`gradle.properties` 的 `projectGroup`）
- `artifactId` = `bjca-footstone-bpring-` + 原模块名去掉 `spring-` 前缀（如 `spring-core` → `bjca-footstone-bpring-core`）
- `version` = `6.2.19-nes.patch.1-SNAPSHOT`（开发）或 `6.2.19-nes.patch.1`（发布）

#### Scenario: spring-core 发布坐标

- **WHEN** 执行 `publishToMavenLocal` 或 `publish` 发布 `spring-core`
- **THEN** 坐标为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1-SNAPSHOT`

#### Scenario: BOM 发布坐标

- **WHEN** 发布 `framework-bom`
- **THEN** 坐标为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT`

### Requirement: Java 包兼容性

GAV 重品牌 MUST NOT 修改任何 `org.springframework.*` Java package、类名或 import 路径。

#### Scenario: 下游仅改依赖

- **WHEN** 业务项目将依赖从 `org.springframework:spring-context` 换为 NES 坐标
- **THEN** 业务 Java 源码中的 `import org.springframework.*` 无需修改

### Requirement: manifest 元数据脱敏

每个 `spring-*` 模块 JAR 的 `MANIFEST.MF` MUST 满足：

- `Implementation-Title` = 重品牌 artifact 名（如 `bjca-footstone-bpring-core`）
- `Implementation-Version` = `originalVersion`（`6.2.19`）
- `Automatic-Module-Name` = 重品牌模块名（如 `bjca.footstone.bpring.core`）

#### Scenario: SpringVersion 运行时版本

- **WHEN** 应用调用 `SpringVersion.getVersion()`
- **THEN** 返回值 MUST 为 `6.2.19`

### Requirement: POM 元数据脱敏

Maven POM MUST NOT 包含将制品识别为官方 Spring Projects 的 organization / scm / developer 信息；MUST 指向 atbjca 组织信息。

#### Scenario: POM organization

- **WHEN** 检查任意 `spring-*` 模块生成的 POM
- **THEN** `organization.name` 为 `BJCA`，而非 `Spring IO`

### Requirement: GAV 映射文档

`doc/GAV_MAPPING.md` MUST 列出全部 24 个 `spring-*` 模块及 `framework-bom` 的原始坐标与 NES 坐标对照表。

#### Scenario: spring-core-test 纳入映射

- **WHEN** 查阅 `doc/GAV_MAPPING.md`
- **THEN** 包含 `spring-core-test` → `bjca-footstone-bpring-core-test` 条目

### Requirement: 与 Boot NES 栈对齐

`projectGroup` 与 `version` 命名 MUST 与 Spring Boot 2.7 NES 的 `forkGroupIdBase` / `nes.patch` 规范一致，便于同一下游同时引用 Boot 与 Framework NES 制品。

#### Scenario: 属性对照可查

- **WHEN** 阅读 `doc/REQUIREMENTS.md` 或 `openspec/changes/6.2-nes-gav-rebrand/design.md`
- **THEN** 可找到 Framework `projectGroup` 与 Boot `forkGroupIdBase` 的对照说明
