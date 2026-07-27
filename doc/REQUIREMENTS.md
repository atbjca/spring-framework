# 业务需求说明 (REQUIREMENTS.md)

## 背景

我们 fork 并维护 Spring Framework **6.2.x**（`6.2.x-bjca-patch` 分支），在官方 release 基线之上自行加固并发布到公司 Nexus。下游业务需通过 SCA 扫描，但工具常将 `org.springframework:spring-*` 识别为有漏洞的官方组件。

## 目标

在**不修改任何 Java 源码 package / 类名 / import** 的前提下：

- 发布坐标改为 NES 自有 GAV，降低 SCA 误报
- 运行时 `SpringVersion.getVersion()` 仍返回上游基线 **`6.2.19`**

## GAV 规范

| 属性 | 值 | 说明 |
|------|-----|------|
| `projectGroup` | `cn.bjca.footstone.bpring` | 与 Boot 2.7 NES 的 `forkGroupIdBase` 一致 |
| `version` | `6.2.19-nes.patch.1-SNAPSHOT` | Maven 发布版本 |
| `originalVersion` | `6.2.19` | 上游基线；写入 manifest，供 `SpringVersion` 使用 |
| artifactId 前缀 | `bjca-footstone-bpring-` | 如 `spring-core` → `bjca-footstone-bpring-core` |

正式发版时去掉 `-SNAPSHOT`，例如 `6.2.19-nes.patch.1`。

## 关键约束

1. 仅改构建脚本与元数据，**保持 `org.springframework.*` 包名不变**。
2. manifest `Implementation-Version` 使用 **`originalVersion`**，不用带 `nes.patch` 的 `version`。
3. 与 Spring Boot 2.7 NES 栈对齐：Boot 的 `springFrameworkVersion` 应指向本 fork 的 `6.2.19-nes.patch.1`（升级 Boot 线时配置）。

## 相关文档

- [OpenSpec 变更提案](../openspec/changes/archive/2026-07-27-6.2-nes-gav-rebrand/proposal.md)（已实施并归档）
- [GAV 映射表](GAV_MAPPING.md)
- [GroupId 维护](GROUP_ID_MAINTENANCE.md)
- [快速入门](QUICK_START.md)
- [测试指南](TESTING.md)
