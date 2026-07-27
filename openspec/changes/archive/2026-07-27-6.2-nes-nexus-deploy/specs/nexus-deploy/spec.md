## ADDED Requirements

### Requirement: Nexus 发布仓库配置

所有启用 `maven-publish` 的子项目 MUST 将制品发布至内网 Nexus。发布 URL MUST 根据项目 `version` 自动选择：

- 以 `-SNAPSHOT` 结尾 → `nexusSnapshotUrl`
- 否则 → `nexusReleaseUrl`

凭证 MUST 从 `~/.gradle/gradle.properties` 读取 `nexusUsername`、`nexusPassword`。HTTP 内网仓库 MUST 设置 `allowInsecureProtocol = true`。

#### Scenario: SNAPSHOT 发布到 snapshots 仓库

- **WHEN** 项目版本为 `6.2.19-nes.patch.1-SNAPSHOT` 且执行 `publish`
- **THEN** Gradle 使用 `nexusSnapshotUrl` 作为发布目标
- **AND** 任务日志包含 `publishMavenJavaPublicationToNexusRepository`

#### Scenario: Release 发布到 releases 仓库

- **WHEN** 项目版本为 `6.2.19-nes.patch.1`（无 SNAPSHOT 后缀）且执行 `publish`
- **THEN** Gradle 使用 `nexusReleaseUrl` 作为发布目标

### Requirement: Make deploy 入口

项目 MUST 提供 `make deploy`，等价于：

```bash
gradle clean publish -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial
```

使用默认 `~/.gradle` 作为 Gradle 用户目录（含 Nexus 配置）。

#### Scenario: 开发者发布 SNAPSHOT

- **WHEN** 开发者已在 `~/.gradle/gradle.properties` 配置 Nexus 凭证
- **AND** 执行 `make deploy`
- **THEN** 构建成功且 NES 坐标制品出现在 Nexus snapshots 仓库

#### Scenario: 缺少 Nexus 配置

- **WHEN** `~/.gradle/gradle.properties` 缺少 `nexusSnapshotUrl` 或凭证
- **THEN** `make deploy` 失败并给出 Gradle 配置/连接错误（不得静默发布到 Maven Central）

### Requirement: 发布文档

`doc/NEXUS_DEPLOY.md` MUST 描述：

- 凭证配置路径（`~/.gradle/gradle.properties`）
- `make deploy` 命令
- 至少两个 NES 坐标示例（core + framework-bom）
- 密码不得出现在仓库文档中（使用 `***` 占位）

#### Scenario: 新成员按文档发布

- **WHEN** 阅读 `doc/NEXUS_DEPLOY.md` 并按步骤配置本地 Gradle 属性
- **THEN** 可在 5 分钟内执行 `make deploy` 并完成一次 SNAPSHOT 上传

### Requirement: 依赖解析不在范围

本 capability MUST NOT 要求在 `settings.gradle` 或 `build.gradle` 的 `repositories` 中配置 Nexus。构建 MAY 继续从 mavenCentral / repo.spring.io 解析依赖。

#### Scenario: 外网依赖解析不影响发布

- **WHEN** 开发者可访问 mavenCentral 完成 `make deploy` 所需的 compile
- **THEN** 制品仍 ONLY 上传至内网 Nexus（不发布到公网仓库）
