## Why

`6.2.x-bjca-patch` 分支已完成本地构建/测试基建（Corretto 17、`make test`），但制品仍为官方 `org.springframework:spring-*` 坐标。公司 SCA 扫描会将已自维护的 Framework 识别为有漏洞的官方组件并阻断发布。

需参照已落地的 **Spring Framework 5.3 NES** 与 **Spring Boot 2.7 NES** 模式，为 6.2.x 建立 GAV 重品牌与元数据脱敏能力，使下游仅改依赖坐标即可接入，**无需改 Java import**。

## What Changes

- `gradle.properties` 引入 `projectGroup`、`version`、`originalVersion`（`6.2.19-nes.patch.1-SNAPSHOT` / `6.2.19`）
- Gradle 发布坐标：`cn.bjca.footstone.bpring:bjca-footstone-bpring-*`
- JAR manifest / POM 去除官方 Spring 指纹（Implementation-Title、organization、scm 等）
- manifest `Implementation-Version` 使用 `originalVersion`，保证 `SpringVersion.getVersion()` 返回 `6.2.19`
- 新增 `doc/REQUIREMENTS.md`、`GAV_MAPPING.md`、`QUICK_START.md`、`GROUP_ID_MAINTENANCE.md`
- 扩展 `Makefile`：`build-thin`、`install`、`deploy`

## Capabilities

### New Capabilities

- `gav-rebrand`: NES GAV 转换、manifest/POM 元数据策略、与 Boot 2.7 NES 命名对齐
- `nes-build-workflow`: 本地构建、测试、安装、发布的 Make 封装与验证门禁

### Modified Capabilities

（无——`openspec/specs/` 下尚无既有 capability spec）

## Impact

- **构建脚本**: `gradle.properties`、`build.gradle`、`gradle/spring-module.gradle`、`gradle/publications.gradle`、`framework-bom/`、各模块 `description`
- **文档**: `doc/*`、`README.md`
- **不受影响**: `org.springframework.*` package、Java 源码、业务 import
- **下游**: 需批量替换 Maven/Gradle 依赖坐标；Boot 线后续需将 `springFrameworkVersion` 指向本 fork
- **范围外**: CVE backport（单独 change）、Gradle wrapper 改本地路径（可选）

## Non-Goals

- 不修改 Java 源码 package / 类名
- 不在本 change 内处理 CVE 评估与 backport
- 不重品牌内部模块 `framework-platform`（不对外发布）
- 不升级 Spring 大版本（6.2 → 7.x）

## 流程说明（纠偏）

本 change **必须先完成 OpenSpec 审批，再实施代码**。若工作区已存在未提交的 Gradle 改动，视为待审草案，**须在 `/opsx:apply` 或人工确认后方可 commit**。
