## Context

| 维度 | 现状 |
|------|------|
| 分支 | `6.2.x-bjca-patch` |
| 版本 | `6.2.19-nes.patch.1-SNAPSHOT` |
| GAV | `cn.bjca.footstone.bpring:bjca-footstone-bpring-*` |
| Nexus | `http://192.168.131.36:8088`（内网） |
| 参考 | 5.3 NES `spring-framework`、`spring-boot-2.7` NES |

用户确认：**publish 必须走内网私服**；**resolve 不影响打包则不必改**。

## Goals / Non-Goals

**Goals:**

- `make deploy` 将所有 maven-publish 模块上传至 Nexus
- SNAPSHOT 版本 → `nexusSnapshotUrl`；非 SNAPSHOT → `nexusReleaseUrl`
- 凭证从 `~/.gradle/gradle.properties` 读取（Gradle 默认行为）
- 文档与 Make help 与实现一致

**Non-Goals:**

- `settings.gradle` / `build.gradle` 依赖仓库接入 Nexus
- 替换 `gradle/publications.gradle` 中上游 `deploymentRepository` 可选路径（保留作应急 `-PdeploymentRepository=`）
- 发布 `framework-platform`（不对外）

## Decisions

### D1: 发布仓库配置位置

在 `build.gradle` 末尾使用 `allprojects { plugins.withType(MavenPublishPlugin) { publishing.repositories.maven } }`，与 5.3 NES 一致。

**理由**: 一次配置覆盖所有子模块（含 `framework-bom`、`framework-api`），避免逐模块重复。

### D2: 凭证与 URL 来源

仅依赖 Gradle 默认加载的 `~/.gradle/gradle.properties`：

```properties
nexusSnapshotUrl=...
nexusReleaseUrl=...
nexusUsername=...
nexusPassword=...
systemProp.http.allowInsecureProtocol=true
```

**理由**: 与 Boot 2.7 NES 共用同一配置文件；密码不入库。

### D3: 不改造 dependency resolution

保持 `configure(allprojects) { repositories { mavenCentral(); repo.spring.io } }` 不变。

**理由**: 用户确认 resolve 不影响打包；减少与上游 Spring 构建脚本的 diff。

### D4: deploy 命令

```makefile
deploy:
	$(GRADLE_CMD) clean publish -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial $(GRADLE_ARGS)
```

跳过测试与文档生成以缩短发布耗时（与 5.3 NES 一致）。

## 发布模块范围

| 类别 | 模块 |
|------|------|
| 核心 | 全部 `spring-*`（含 `spring-core-test`） |
| BOM | `framework-bom` |
| 附加 | `framework-api`（含 docs/schema zip）、`framework-docs` |
| 不发布 | `framework-platform`、`integration-tests` |

## 验证

1. `make deploy` → `BUILD SUCCESSFUL`
2. Gradle 日志出现 `publishMavenJavaPublicationToNexusRepository`
3. Nexus UI 可见示例坐标：
   - `cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1-SNAPSHOT`
   - `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT`

## Risks

| 风险 | 缓解 |
|------|------|
| Nexus 不可达 | 内网 VPN / 网络；发布失败时 Gradle 报 401/连接错误 |
| 凭证过期 | 更新 `~/.gradle/gradle.properties`，不入库 |
| `clean publish` 耗时长 | 可接受；与 5.3 一致 |
