## Why

`Makefile` 在多个 Gradle 入口中强制设置仅存在于单台 macOS 主机上的 `JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem`。这会覆盖调用者原本有效的 Java 环境，并导致 Linux、CI 或其他开发机在执行 `make clean`、`make build` 等目标时立即报错。

## What Changes

- 删除 `clean`、`build`、`build-thin`、`install`、`deploy`、`docs` 和 `checkstyle` recipe 中硬编码的 `JAVA_HOME` 前缀。
- 让 `./gradlew` 按标准行为使用调用者提供的有效 `JAVA_HOME`，或在未设置时使用 `PATH` 中的 `java`。
- 保留现有 Gradle 任务、参数、目标依赖和 `TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11` 配置不变。
- 不在 Makefile 中新增平台相关的 JDK 路径探测逻辑。
- 不新增 `test` Make 目标，也不修改 Gradle Wrapper 发行包配置；这两个问题作为独立后续工作处理。

## Capabilities

### New Capabilities

- `portable-gradle-java-launch`: Make 构建入口不得覆盖调用者的 Java 环境为机器专属路径，并应委托 Gradle Wrapper 执行标准 Java 启动选择。

### Modified Capabilities

无。

## Impact

- 受影响文件：`Makefile`。
- 受影响目标：`clean`、`build`、`build-thin`、`install`、`deploy`、`docs`、`checkstyle`。
- API、源码、依赖和构建产物格式均不变。
- 构建机仍需提供可启动 Gradle 的 Java；涉及编译和测试的目标仍通过既有 toolchain 参数要求 JDK 8 与 JDK 11。
- `gradle/wrapper/gradle-wrapper.properties` 中现存的机器专属发行包路径不在本变更范围内，可能继续影响 Linux 上的端到端构建。
