## Why

NES GAV 重品牌（`6.2-nes-gav-rebrand`）已完成坐标与 manifest 改造，下游需从**公司内网 Nexus** 拉取 `cn.bjca.footstone.bpring:*` 制品。发布链路须与 5.3 NES / Boot 2.7 NES 一致：凭证与 URL 放在 `~/.gradle/gradle.properties`，`make deploy` 上传至 snapshots 或 releases。

当前实现已在 `build.gradle` 配置全局 `publish` 仓库，但文档与 OpenSpec 仍引用上游的 `deploymentRepository` 参数；改回默认 `~/.gradle` 后须重新验证发布成功。

## What Changes

- 固化 `build.gradle` 中 `allprojects { publishing.repositories.maven → Nexus }` 配置（SNAPSHOT / Release 自动路由）
- 确认 `make deploy` 使用 `~/.gradle/gradle.properties` 中的 `nexus*` 属性
- 更新 `doc/NEXUS_DEPLOY.md`、`Makefile` help、`nes-build-workflow` spec 中的表述（去除 `deploymentRepository` 误导）
- 审批后 commit 未提交的 `~/.gradle` 默认化改动

## Capabilities

### New Capabilities

- `nexus-deploy`: NES Framework 6.2 制品发布至内网 Nexus 的 Gradle 配置、Make 入口与验证门禁

### Modified Capabilities

- `nes-build-workflow`: `make deploy` 前置条件改为 `~/.gradle/gradle.properties` 中的 Nexus 配置

## Impact

- **构建脚本**: `build.gradle`（publish 仓库，已存在）、`Makefile`（help 文案）
- **文档**: `doc/NEXUS_DEPLOY.md`、`doc/TESTING.md`
- **凭证**: 仅本地 `~/.gradle/gradle.properties`，**不得**写入仓库
- **不受影响**: 依赖解析（`repositories` 仍可用 mavenCentral / repo.spring.io，不影响打包）
- **下游**: Boot 线 / 业务项目从 Nexus snapshots 引用 `6.2.19-nes.patch.1-SNAPSHOT`

## Non-Goals

- 不在 `settings.gradle` / `build.gradle` 的 `repositories` 中接入 Nexus（resolve 走公网即可）
- 不修改 GAV 规则（属 `6.2-nes-gav-rebrand`）
- 不处理 CVE backport
- 不在仓库中保存 Nexus 密码

## 与 Boot 2.7 NES / 5.3 NES 对照

| 项 | 5.3 / Boot NES | 6.2 本 change |
|----|----------------|---------------|
| 凭证位置 | `~/.gradle/gradle.properties` | 同左 |
| SNAPSHOT 仓库 | `nexusSnapshotUrl` | 同左 |
| Release 仓库 | `nexusReleaseUrl` | 同左 |
| 发布命令 | `make deploy` | 同左 |
| 依赖解析 Nexus | 5.3 有 | **不在范围** |

## 流程说明

本 change **须 OpenSpec 审批后再 commit**。工作区中 publish 相关 Gradle 改动与 `~/.gradle` 默认化补丁视为待审草案。
