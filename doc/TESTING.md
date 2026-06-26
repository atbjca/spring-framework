# 测试指南 (TESTING.md)

本文档说明如何在 `6.2.x-bjca-patch` 分支上配置环境、运行测试，以及在安全补丁开发中遵循的 TDD 约定。

---

## 1. 快速开始

```bash
# 查看可用命令
make help

# 全量测试（推荐）
make test

# 仅测试单个模块
make test-module M=spring-core
```

**首次全量测试参考耗时**：约 40 分钟（视机器与缓存情况而定）。  
**已验证环境**（2026-06-26）：`make test` → `BUILD SUCCESSFUL`，219 个任务，无失败。

---

## 2. 环境要求

### 2.1 JDK

| 项目 | 要求 |
|------|------|
| 版本 | **Java 17** |
| 发行版 | **Amazon Corretto**（与 `buildSrc/JavaConventions.java` 中 `JvmVendorSpec.AMAZON` 一致） |
| 推荐路径 | `~/.sdkman/candidates/java/17.0.17-amzn`（sdkman 安装） |

安装示例：

```bash
sdk install java 17.0.17-amzn
sdk use java 17.0.17-amzn
```

> **说明**：上游 Spring 官方 CI 默认使用 BellSoft Liberica 17。本分支已改为 Amazon Corretto，以便在本地 sdkman 环境直接构建，无需从网络下载 Liberica。

### 2.2 Gradle

| 项目 | 要求 |
|------|------|
| 版本 | **8.14.x**（与 `gradle/wrapper/gradle-wrapper.properties` 一致） |
| 推荐路径 | `~/dev/gradle-8.14.5/bin/gradle`（本地解压，避免 wrapper 远程下载） |

若 `~/dev/gradle-8.14.5` 不存在，`Makefile` 会自动回退到项目内 `./gradlew`（可能触发网络下载，较慢）。

### 2.3 磁盘与缓存

编译、测试产生的依赖缓存与 Daemon 数据默认放在：

```
~/Downloads/DELETE/tmp/gradle-home
```

可通过环境变量 `GRADLE_USER_HOME` 覆盖，避免占满系统盘。

---

## 3. Makefile 命令

| 命令 | 说明 |
|------|------|
| `make test` | 运行全项目 `gradle test`（所有 `spring-*` 模块 + `integration-tests`） |
| `make test-module M=<模块名>` | 仅运行指定模块，如 `M=spring-webmvc` |
| `make clean` | 清理构建产物 |
| `make stop` | 停止 Gradle Daemon |
| `make projects` | 列出所有 Gradle 子项目 |
| `make help` | 显示帮助与环境变量默认值 |

### 3.1 覆盖环境变量

```bash
# 使用其他 JDK 路径
JDK17=$HOME/.sdkman/candidates/java/17.0.12-oracle make test

# 使用其他 Gradle 缓存目录
GRADLE_USER_HOME=/path/to/cache make test
```

---

## 4. 直接使用 Gradle（不使用 Make）

与 `Makefile` 等价的命令：

```bash
export JDK17="$HOME/.sdkman/candidates/java/17.0.17-amzn"
export GRADLE_USER_HOME="$HOME/Downloads/DELETE/tmp/gradle-home"

~/dev/gradle-8.14.5/bin/gradle test \
  -Porg.gradle.java.installations.fromEnv=JDK17 \
  --no-daemon
```

单模块示例：

```bash
~/dev/gradle-8.14.5/bin/gradle :spring-expression:test \
  -Porg.gradle.java.installations.fromEnv=JDK17 \
  --no-daemon
```

### 4.1 指定测试用 JDK 版本（可选）

项目支持通过 `testToolchain` 属性用不同 JDK 版本**编译和运行测试**（见 `gradle/toolchains.gradle`）：

```bash
# 使用 JDK 22 跑测试（需本地已安装并在 JDK22 环境变量中注册）
export JDK22=/path/to/jdk22
~/dev/gradle-8.14.5/bin/gradle test \
  -PtestToolchain=22 \
  -Porg.gradle.java.installations.fromEnv=JDK17,JDK22 \
  --no-daemon
```

---

## 5. 测试范围与模块

全量 `make test` 覆盖的主要模块包括：

| 类别 | 模块示例 |
|------|----------|
| 核心 | `spring-core`、`spring-beans`、`spring-context`、`spring-expression` |
| Web | `spring-web`、`spring-webmvc`、`spring-webflux`、`spring-websocket` |
| 数据 / 消息 | `spring-jdbc`、`spring-orm`、`spring-jms`、`spring-r2dbc`、`spring-tx` |
| 其他 | `spring-aop`、`spring-test`、`spring-messaging` 等 |
| 集成 | `integration-tests` |

`framework-docs` 等文档模块通常无测试源码（`test NO-SOURCE`），属正常现象。

查看完整列表：

```bash
make projects
```

---

## 6. 测试框架与命名约定

本项目测试基于 **JUnit 5**（JUnit Jupiter），配置见根目录 `build.gradle`：

- 测试类命名：`**/*Tests.class` 或 `**/*Test.class`
- 断言库：AssertJ、Mockito、MockK（Kotlin 模块）等

新增测试请遵循上游惯例：

- 单元测试类名以 `Tests` 或 `Test` 结尾
- 放在对应模块的 `src/test/java`（或 `src/test/kotlin`）下，包路径与被测类一致

---

## 7. 安全补丁开发的 TDD 流程

对本分支后续 CVE backport，建议严格按以下顺序：

```
1. 阅读官方 advisory 与修复 commit
2. 先编写/移植失败用例（重现漏洞或回归场景）
3. 实现最小化修复
4. make test-module M=<受影响模块>   # 模块级验证
5. make test                         # 全量回归
6. 更新 doc/VULNERABILITY_FIXES.md 等文档
```

**覆盖度要求**：核心业务逻辑与复杂算法相关变更，测试覆盖度目标 ≥ 60%；纯配置、简单数据模型可酌情豁免。

---

## 8. 测试报告与日志

| 产物 | 路径 |
|------|------|
| 全量测试日志（手动 tee 时） | `~/Downloads/DELETE/tmp/spring-framework-full-test.log` |
| 各模块 HTML 报告 | `<模块>/build/reports/tests/test/index.html` |
| 问题汇总（Gradle 8+） | `build/reports/problems/problems-report.html` |

查看某模块报告示例：

```bash
open spring-core/build/reports/tests/test/index.html
```

---

## 9. 常见问题

### Q1：`Cannot find a Java installation ... BellSoft Liberica`

本分支应已改为 **Amazon Corretto**。若仍出现 Liberica 相关错误，请确认：

1. `buildSrc/.../JavaConventions.java` 中 vendor 为 `JvmVendorSpec.AMAZON`
2. 已安装 Corretto 17 且 `JDK17` 路径正确
3. 修改 `buildSrc` 后需重新编译：先执行任意 gradle 命令触发 `buildSrc` 重建

### Q2：`JDK17 不存在`

```bash
sdk install java 17.0.17-amzn
# 或指定路径
JDK17=/your/jdk17/path make test
```

### Q3：Gradle 下载很慢

使用本地 Gradle，勿依赖 wrapper 远程地址：

```bash
unzip -q ~/dev/gradle-8.14.5-bin.zip -d ~/dev/
```

确保 `~/dev/gradle-8.14.5/bin/gradle` 存在。

### Q4：磁盘空间不足

```bash
export GRADLE_USER_HOME=~/Downloads/DELETE/tmp/gradle-home
make clean
make stop
```

### Q5：单模块通过但全量失败

先定位失败模块：

```bash
# 查看日志中的 FAILED
grep -E "FAILED|BUILD FAILED" ~/Downloads/DELETE/tmp/spring-framework-full-test.log

# 单独重跑
make test-module M=spring-webflux
```

---

## 10. 与上游的差异摘要

| 项目 | 上游 Spring 6.2 | 本分支 |
|------|-----------------|--------|
| JDK Toolchain Vendor | BellSoft Liberica | **Amazon Corretto** |
| 本地构建入口 | `./gradlew` | **`Makefile`（`make test`）** |
| Gradle 缓存 | 默认 `~/.gradle` | 默认 `~/Downloads/DELETE/tmp/gradle-home` |

---

## 11. 相关文件

| 文件 | 说明 |
|------|------|
| `Makefile` | 本地测试与构建封装 |
| `buildSrc/.../JavaConventions.java` | Java 17 + Corretto toolchain 配置 |
| `gradle/toolchains.gradle` | 测试 JDK 版本切换（`testToolchain`） |
| `build.gradle` | JUnit 5 与全局测试依赖 |
