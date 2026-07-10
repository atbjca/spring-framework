## Why

Spring Framework 5.3 fork（`cn.bjca.footstone.bpring`）的构建产物在 **JDK 8 运行时会抛 `NoSuchMethodError` 并静默挂起**，根因是编译配置缺陷：

- `make deploy` 用 JDK 11（`11.0.30-tem`）编译，但**未传 `-PmainToolchain=8`**，触发 `gradle/toolchains.gradle` 的 fallback 分支 —— 只设 `sourceCompatibility = 1.8`（即 `-source 8 -target 8`），**没有 `--release 8`**。
- 后果：编译器用 JDK 11 的 bootclasspath 做符号解析，却打上 JDK 8 字节码版本戳（major 52）。JDK 9+ 给 `ByteBuffer.position/limit/clear/flip` 引入了协变返回类型（返回 `ByteBuffer` 而非 `Buffer`），编译器把调用点描述符固化成 `()Ljava/nio/ByteBuffer;`。
- JDK 8 运行时这些方法实际返回 `java.nio.Buffer` —— 描述符不匹配 → `NoSuchMethodError`。

**已通过 `javap` 字节码实证**（详见 design.md）：现有 `DefaultDataBuffer.class`（major 52）中 `clear/limit/position` 全部固化为 `…Ljava/nio/ByteBuffer;`，JDK 8 不存在该签名。

**危害路径**：`DataBufferUtils` 异步文件读取在 `AsynchronousFileChannel` 完成回调线程里操作 `DefaultDataBuffer`，`NoSuchMethodError` 被回调线程静默吞掉 → 完成信号永不产生 → `Mono.block()` 永久挂起（现象：无 IO 线程、main 死等）。

## What Changes

> **实现修正**：初始选方案 A（`options.release = 8`）。实现阶段发现 `--release 8` 使用历史 `ct.sym`，不含 `jdk.jfr`（8u262+ backport），与 `spring-core` 的 `metrics/jfr` 包冲突编不过。改为 **方案 B（真 JDK 8 toolchain）**，详见 design.md D1。

- **构建配置修复**：`Makefile` 各编译 main 的目标（`build`/`build-thin`/`install`/`deploy`）注入 `TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11`，用真实 JDK 8 toolchain 编译 main —— 既让 ByteBuffer 协变调用解析到 `java.nio.Buffer` 父类签名，又保留 `jdk.jfr`（真 JDK 8u262+ 的 backport）可编译。
- **严格作用域**：`-PtestToolchain=11` 确保 test 编译/运行仍在 JDK 11，继续可用 JDK 9+ API（如 `InputStream.transferTo()`）。
- **零源码改动、零上游分叉**：`-PmainToolchain=8 -PtestToolchain=11` 是 `gradle/toolchains.gradle` 内置设计的用法，仅在 `Makefile` 调用处补传参数。

## Capabilities

### New Capabilities
- `jdk8-bytecode-compatibility`: main 源码编译产物必须与 JDK 8 运行时二进制兼容（协变返回类型方法解析到 `java.nio.Buffer` 父类签名）

### Modified Capabilities
（无既有 capability 变更）

## Impact

- **受影响模块**: `Makefile`（发布/编译入口），间接影响所有 `spring-*` 模块的 main 产物
- **受影响文件**:
  - `Makefile` — 新增 `TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11`，注入 `build`/`build-thin`/`install`/`deploy`
  - `doc/JDK8_COMPATIBILITY.md` — 新增，记录根因/修复/验收命令
- **修复覆盖点**（javap 实证的 3 类协变调用，修复后全部翻转为 `…Ljava/nio/Buffer;`）:
  - `spring-core` `DefaultDataBuffer`（clear/limit/position 多处）
  - `spring-core` `ByteBufferDecoder`（flip×1）
  - `spring-web` `UndertowServerHttpRequest$RequestBodyPublisher`（flip×1）
- **测试影响**: **无**。`-PtestToolchain=11` 保证 test 仍用 JDK 11 编译/运行，`InputStream.transferTo()`（JDK 9 API）等照常可用（实测 `compileTestJava` BUILD SUCCESSFUL）
- **向后兼容性**: 完全兼容，无 API 变更
- **与上游一致性**: 直接采用上游 `gradle/toolchains.gradle` 内置的 `-PmainToolchain=8 -PtestToolchain=11` 开关，零源码分叉
- **前提**: 构建机需装 JDK 8（本机 `8.0.472-amzn`，Gradle 经 SDKMAN! 自动发现）
- **依赖**: 无新依赖
- **验证结论**: 全量 `make build-thin` BUILD SUCCESSFUL（198 tasks）；JDK 8u472 运行时实测协变调用无 `NoSuchMethodError`；对照组确认旧产物在 JDK 8 必崩
