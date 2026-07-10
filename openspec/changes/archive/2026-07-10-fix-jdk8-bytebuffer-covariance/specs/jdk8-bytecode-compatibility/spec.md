## ADDED Requirements

### Requirement: main 产物与 JDK 8 运行时二进制兼容
所有 `spring-*` 模块的 main 源码编译产物 SHALL 与 JDK 8 运行时二进制兼容。对 JDK 9+ 引入协变返回类型的方法（`java.nio.ByteBuffer.position/limit/clear/flip/rewind` 等），调用点的方法描述符 MUST 解析到 JDK 8 中存在的父类签名（返回 `java.nio.Buffer`），而非 JDK 9+ 的协变签名（返回 `java.nio.ByteBuffer`）。

实现方式 MUST 用真实 JDK 8 toolchain 编译 main（Gradle `-PmainToolchain=8`），而非 `javac --release 8`——因为 `--release 8` 使用历史 `ct.sym`，不含 `jdk.jfr`（8u262+ backport），会与 `spring-core` 的 `metrics/jfr` 包冲突而编译失败。

#### Scenario: main 编译产物的协变方法解析到 Buffer 父类签名
- **WHEN** 对编译后的 `DefaultDataBuffer.class` / `ByteBufferDecoder.class` / `UndertowServerHttpRequest$RequestBodyPublisher.class` 执行 `javap -c -p`
- **THEN** `ByteBuffer.clear/limit/position/flip` 调用点的描述符 MUST 为 `…Ljava/nio/Buffer;`，且 class major version MUST 为 52（JDK 8）

#### Scenario: JDK 8 运行时异步文件读取不崩溃
- **WHEN** 在 JDK 8 运行时通过 `DataBufferUtils.readAsynchronousFileChannel(...)` 读取文件并 `Mono.block()`
- **THEN** `AsynchronousFileChannel` 完成回调 MUST NOT 抛 `NoSuchMethodError`，完成信号正常产生，`block()` 正常返回而非永久挂起

### Requirement: test 编译不受 JDK 8 API 边界约束
test 源码编译/运行（`compileTestJava` / `compileTestFixturesJava` / `Test`）MUST 保持在 JDK 11（`-PtestToolchain=11`），以保持对 JDK 9+ API 的可用性。JDK 8 编译约束仅适用于 main 编译。

#### Scenario: test 代码可使用 JDK 9+ API
- **WHEN** test 源码调用 JDK 9+ API（如 `InputStream.transferTo()`）且构建带 `-PmainToolchain=8 -PtestToolchain=11`
- **THEN** `compileTestJava` MUST 编译通过（test 用 JDK 11 toolchain，不受 main 的 JDK 8 约束）
