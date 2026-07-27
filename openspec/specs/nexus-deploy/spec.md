# nexus-deploy Specification

## Purpose

定义 Spring Framework 6.2 NES 制品发布到内网 Nexus 的仓库路由、凭证边界和验证要求。

## Requirements

### Requirement: Nexus 发布仓库配置

所有启用 `maven-publish` 的子项目 MUST 根据版本将 SNAPSHOT 发布到 `nexusSnapshotUrl`、将非 SNAPSHOT 发布到 `nexusReleaseUrl`，并从 `~/.gradle/gradle.properties` 读取凭证。

#### Scenario: SNAPSHOT 发布到 snapshots 仓库

- **WHEN** 项目版本以 `-SNAPSHOT` 结尾且执行 `publish`
- **THEN** Gradle 使用 `nexusSnapshotUrl` 作为发布目标

#### Scenario: Release 发布到 releases 仓库

- **WHEN** 项目版本不以 `-SNAPSHOT` 结尾且执行 `publish`
- **THEN** Gradle 使用 `nexusReleaseUrl` 作为发布目标

### Requirement: Make deploy 入口

项目 MUST 提供使用默认 `~/.gradle` 的 `make deploy` 发布入口。

#### Scenario: 缺少 Nexus 配置

- **WHEN** 必要 Nexus URL 或凭证缺失
- **THEN** `make deploy` 失败且不得静默发布到 Maven Central

### Requirement: 发布文档

`doc/NEXUS_DEPLOY.md` MUST 描述配置路径、发布命令、core 与 BOM 坐标示例，并且 MUST NOT 包含密码。

#### Scenario: 新成员按文档发布

- **WHEN** 新成员按发布文档配置环境
- **THEN** 可执行 `make deploy` 完成发布

### Requirement: 依赖解析不在范围

发布 capability MUST NOT 要求依赖解析仓库接入 Nexus。

#### Scenario: 外网依赖解析不影响发布

- **WHEN** 构建从公开仓库完成依赖解析
- **THEN** 制品仍只上传至内网 Nexus
