## Context

| 维度 | 现状 |
|------|------|
| 分支 | `6.2.x-bjca-patch` |
| 上游基线 | Spring Framework 6.2.19（`originalVersion`） |
| 测试 | `make test` 全绿（Corretto 17） |
| 参考实现 | `spring-framework` 5.3 NES、`spring-boot-2.7` NES |

### 与 Boot 2.7 NES 属性对照

| Framework 6.2（本 change） | Boot 2.7 NES | 值 |
|---------------------------|--------------|-----|
| `projectGroup` | `forkGroupIdBase` | `cn.bjca.footstone.bpring` |
| `version` | `version` | `*-nes.patch.1-SNAPSHOT` |
| `originalVersion` | `springBootVersion` | 上游 release 号（`6.2.19`） |
| artifact 前缀 | `forkArtifactPrefix` | `bjca-footstone-bpring` |

## Goals / Non-Goals

**Goals:**

- SCA 扫描不再将制品误判为官方 `org.springframework` 有漏洞组件
- Maven 坐标与 5.3 / Boot NES 栈命名一致
- `SpringVersion.getVersion()` 运行时返回 `6.2.19`
- 提供完整 GAV 映射与快速入门文档
- `make build-thin` / `make test` 验证通过

**Non-Goals:**

- CVE 批次评估与 Java 补丁 backport
- 修改 `framework-platform` 发布行为
- 改动 Gradle wrapper 远程地址（另议）

## Decisions

### D1: 版本号

```
originalVersion = 6.2.19
version         = 6.2.19-nes.patch.1-SNAPSHOT
发布版           = 6.2.19-nes.patch.1
```

**理由**: 与 5.3 / Boot NES 的 `nes.patch` 后缀一致；冻结在 6.2.19 release 而非跟踪 `6.2.20-SNAPSHOT`。

### D2: manifest `Implementation-Version`

使用 **`originalVersion`（6.2.19）**，不用带 `nes.patch` 的 `version`。

**理由**: 6.2 的 `SpringVersion.getVersion()` 会按 `.` 截断；若写入 `6.2.19-nes.patch.1` 可能得到 `6.2.19-nes`，破坏框架内部版本语义。

### D3: GAV 转换规则

| 原始 | NES |
|------|-----|
| `org.springframework` | `cn.bjca.footstone.bpring` |
| `spring-core` | `bjca-footstone-bpring-core` |
| `spring-framework-bom` | `bjca-footstone-bpring-framework-bom` |

`spring-core-test` 等 6.2 新增模块纳入 `GAV_MAPPING.md`。

### D4: 实施顺序（OpenSpec 门禁）

```
1. proposal / design / specs / tasks  ← 审批
2. Gradle + doc 实施
3. make build-thin
4. make test
5. make install（可选）
6. commit
```

### D5: JDK Toolchain

维持 `JvmVendorSpec.AMAZON`（Corretto 17），已在独立 commit 中落地，本 change 不重复修改。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 下游未换坐标 | 提供 `GAV_MAPPING.md` + BOM 示例 |
| JPMS 模块名变化 | `Automatic-Module-Name` 随重品牌更新，文档说明 |
| 本地 JAR 文件名仍为 `spring-core-*.jar` | Maven 发布 `artifactId` 已重品牌；必要时后续 change 改 `archiveBaseName` |
| 与上游 merge 冲突 | Gradle 改动集中、可重复应用 |

## Migration Plan

1. 业务项目替换依赖为 NES GAV（或 import BOM）
2. Boot 线将 `springFrameworkVersion` 升级为 `6.2.19-nes.patch.1`
3. 清理 `~/.m2` 中旧坐标缓存
