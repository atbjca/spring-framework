## Context

当前 `Makefile` 在七个 Gradle recipe 前显式赋值 `JAVA_HOME`。其中六处直接使用 `/Users/anan/.sdkman/candidates/java/11.0.30-tem`，`clean` 虽然尝试读取该目录下的 `release` 文件，但失败时仍回退到同一个私有路径。该赋值发生在执行 `./gradlew` 之前，因此会覆盖 Linux、CI 或其他开发机已经配置好的 Java 环境。

Gradle Wrapper 自身已经实现跨平台 Java 启动选择：非空 `JAVA_HOME` 指向可执行 Java 时使用它；未设置时查找 `PATH` 中的 `java`。此外，本项目的 main/test 编译版本由 `TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11` 控制，Gradle 启动 JVM 与编译 toolchain 是不同职责。

## Goals / Non-Goals

**Goals:**

- 消除 Makefile 对单台 macOS 主机 JDK 路径的依赖。
- 尊重调用者提供的 `JAVA_HOME`，并允许 Wrapper 在变量未设置时使用 `PATH`。
- 保持所有现有目标、Gradle 任务、参数、依赖关系和 toolchain 语义不变。
- 将修改限制在 `Makefile`。

**Non-Goals:**

- 不负责安装、下载或自动选择 JDK 8/JDK 11。
- 不为无效的外部 `JAVA_HOME` 静默寻找替代 JDK。
- 不新增 `make test` 目标。
- 不修复 `gradle-wrapper.properties` 的机器专属 `distributionUrl`，也不改动 `scripts/setup-gradle-local.sh`。

## Decisions

### D1: 直接调用 `./gradlew`，不在 Makefile 中探测 JAVA_HOME

删除每个相关 recipe 的 `JAVA_HOME=...` 前缀，保留其后的 `./gradlew` 命令。Wrapper 已具备所需的环境变量和 `PATH` 回退行为，因此额外使用 `uname`、`/usr/libexec/java_home`、SDKMAN 目录扫描或 `readlink` 会重复职责并重新引入平台差异。

考虑过的替代方案是定义 `JAVA_HOME ?= ...` 或在 shell recipe 中条件探测 JDK。该方案仍要求 Makefile 理解各平台的 JDK 安装布局，并可能掩盖调用者错误配置，因此不采用。

### D2: 保留 Gradle toolchain 参数

`build`、`build-thin`、`install` 和 `deploy` 继续传递 `$(TOOLCHAINS)`。启动 Gradle 的 JVM 可以来自调用者环境，而 main/test 的实际编译和测试仍分别使用 JDK 8/JDK 11 toolchain，从而保持既有 JDK 8 字节码兼容性修复。

### D3: 严格保持 recipe 行为

除删除环境变量赋值前缀外，不调整任务顺序、排除项、目标前置依赖或 `.PHONY` 声明。`docs` 和 `checkstyle` 也仅恢复为标准 Wrapper 启动行为，不额外注入 toolchain 参数。

### D4: 将其他可移植性问题作为独立变更

Wrapper 的本地文件 URL 与缺少 `test` Make 目标会影响更宽泛的验收，但它们需要不同的行为决策。当前变更通过静态检查、Make dry-run 和在可用 Wrapper 环境中的目标冒烟来验证，不以新增功能或修改 Wrapper 分发策略为代价扩大范围。

## Risks / Trade-offs

- **[调用者显式设置了无效 JAVA_HOME]** → Wrapper 仍会报错；这是标准且可诊断的行为，调用者应修复或取消该环境变量。
- **[启动 JDK 与历史固定的 JDK 11 不同]** → 编译目标仍由 toolchain 隔离；验证阶段至少运行 Wrapper 启动和 `clean` 冒烟，确认当前支持的启动 JDK 可用。
- **[Wrapper 的硬编码 distributionUrl 阻断 Linux 验证]** → 在结果中明确记录为既有独立问题，不将其误判为本变更回归。
- **[用户期望 `make clean test`]** → 当前 Makefile 本来没有 `test` 目标；本变更不新增目标，验收使用 `make clean` 和包含测试的既有 `make build`，或直接调用相应 Gradle 测试任务。
