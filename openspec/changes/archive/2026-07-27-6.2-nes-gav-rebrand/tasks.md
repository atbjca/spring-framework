# Tasks: 6.2 NES GAV 重品牌

> **流程纠偏**：本任务清单为 OpenSpec 正式交付物。工作区中已存在的 Gradle/doc 改动为**超前实施的草案**，须在本 change 经审批前 **不得 commit**。

## 0. OpenSpec（须最先完成）

- [x] 0.1 创建 `openspec/config.yaml`
- [x] 0.2 创建 `proposal.md`、`design.md`
- [x] 0.3 创建 `specs/gav-rebrand/spec.md`、`specs/nes-build-workflow/spec.md`
- [x] 0.4 创建 `tasks.md`（本文件）
- [x] 0.5 **【需审批】** 项目负责人审阅 OpenSpec 并确认可实施

## 1. Phase A — 文档（审批前可独立阅读）

- [x] 1.1 起草 `doc/REQUIREMENTS.md`（6.2 NES 业务背景）
- [x] 1.2 起草 `doc/GAV_MAPPING.md`（含 `spring-core-test`）
- [x] 1.3 起草 `doc/GROUP_ID_MAINTENANCE.md`
- [x] 1.4 起草 `doc/QUICK_START.md`
- [x] 1.5 更新 `doc/TESTING.md` 版本说明
- [x] 1.6 更新 `README.md` 本地维护链接

## 2. Phase B — Gradle GAV 实施（须 0.5 审批后确认提交）

> 以下条目已在工作区**超前完成**，待审：

- [x] 2.1 `gradle.properties`：`projectGroup` / `version` / `originalVersion`
- [x] 2.2 `build.gradle`：`group = projectGroup`
- [x] 2.3 `gradle/spring-module.gradle`：manifest + `artifactId`
- [x] 2.4 `gradle/publications.gradle`：POM 元数据
- [x] 2.5 `framework-bom/framework-bom.gradle`
- [x] 2.6 各模块 `description` 重品牌

## 3. Phase C — 构建与发布封装

- [x] 3.1 `Makefile` 增加 `build-thin`、`install`、`deploy`
- [x] 3.2 `make build-thin` 验证通过
- [x] 3.3 `make test` 全量回归（GAV 改动后须重跑；`spring-webflux` 偶发失败后重跑通过）
- [x] 3.4 `make install` 试装本地 Maven（可选）

## 4. 收尾

- [x] 4.1 **【需审批】** commit（OpenSpec + 实施改动）
- [x] 4.2 通知下游更新 `springFrameworkVersion`（Boot 线；2026-07-27 已通知中央 RELEASE train）
- [x] 4.3 OpenSpec change 归档（`/opsx:archive`）

## 后续 change（不在本任务内）

- CVE 6.2 批次评估（单独 `openspec/changes/`）
- Gradle wrapper 本地化（`~/dev/gradle-8.14.5`）
- `archiveBaseName` 与本地 JAR 文件名统一（可选）
