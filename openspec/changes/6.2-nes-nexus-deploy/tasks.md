# Tasks: 6.2 NES Nexus 私服发布

> **流程**：本任务清单为 OpenSpec 正式交付物。Gradle/doc 改动须在本 change **审批后** 方可 commit。

## 0. OpenSpec（须最先完成）

- [x] 0.1 创建 `openspec/changes/6.2-nes-nexus-deploy/`
- [x] 0.2 创建 `proposal.md`、`design.md`
- [x] 0.3 创建 `specs/nexus-deploy/spec.md`
- [x] 0.4 创建 `tasks.md`（本文件）
- [x] 0.5 **【需审批】** 项目负责人审阅 OpenSpec 并确认可实施

## 1. Phase A — 文档对齐（审批后可提交）

- [x] 1.1 `doc/NEXUS_DEPLOY.md`（凭证位置、`make deploy`、坐标示例）
- [x] 1.2 `Makefile` help：`deploymentRepository` → `~/.gradle/gradle.properties`
- [x] 1.3 更新 `openspec/changes/6.2-nes-gav-rebrand/specs/nes-build-workflow/spec.md` 中 deploy 前置条件
- [x] 1.4 `doc/TESTING.md` 补充 deploy 验证说明（可选一行）

## 2. Phase B — Gradle 发布配置（工作区已有草案）

- [x] 2.1 `build.gradle`：`allprojects` Nexus publish 仓库
- [x] 2.2 移除 `GRADLE_USER_HOME` 外置与 build.gradle 凭证回退 helper
- [x] 2.3 确认 `gradle/publications.gradle` POM 元数据与 NES GAV 一致

## 3. Phase C — 验证门禁

- [x] 3.1 `make deploy` → BUILD SUCCESSFUL（改回 `~/.gradle` 后，2026-06-26 验证）
- [ ] 3.2 Nexus UI 抽查 `bjca-footstone-bpring-core` 与 `framework-bom`
- [x] 3.3 `make install` 本地试装（GAV change 已验证）

## 4. 收尾

- [x] 4.1 **【需审批后】** commit（OpenSpec + 文档 + Makefile）
- [ ] 4.2 通知下游 Boot 线配置 Nexus snapshots 依赖
- [ ] 4.3 OpenSpec change 归档

## 不在本 change 内

- `settings.gradle` / `repositories` 接入 Nexus（resolve）
- CVE 评估与 backport
