# JDK 8 二进制兼容性（发布必读）

本 fork（`cn.bjca.footstone.bpring`）的产物需在 **JDK 8 运行时**可用。构建机用 JDK 11，但 **main 源码必须用真实 JDK 8 toolchain 编译**，否则会在 JDK 8 运行时抛 `NoSuchMethodError` 并可能静默挂起。

## 根因

`ByteBuffer.position/limit/clear/flip` 在 JDK 9+ 引入了**协变返回类型**（返回 `ByteBuffer`，而非 JDK 8 的 `Buffer`）。

- 若用 JDK 11 编译且**只设** `-source/-target 8`（无 `--release`、无 JDK 8 toolchain），编译器用 JDK 11 的 bootclasspath 解析符号，把调用点描述符固化成 `()Ljava/nio/ByteBuffer;`，却打上 JDK 8 字节码戳（major 52）。
- JDK 8 运行时这些方法实际返回 `java.nio.Buffer` → 描述符不匹配 → **`NoSuchMethodError`**。
- 最隐蔽的表现：`DataBufferUtils` 异步文件读取在 `AsynchronousFileChannel` 完成回调线程操作 `DefaultDataBuffer`，`NoSuchMethodError` 被回调线程静默吞掉 → 完成信号不产生 → `Mono.block()` 永久挂起（无 IO 线程、main 死等，无栈打印）。

受影响类（javap 实证）：`spring-core` `DefaultDataBuffer`、`spring-core` `ByteBufferDecoder`、`spring-web` `UndertowServerHttpRequest$RequestBodyPublisher`。

## 为什么用真实 JDK 8 toolchain，而不是 `--release 8`

`javac --release 8` 使用 JDK 11 内置的**历史 `ct.sym`**（JDK 8 *最初* 的 API 面），**不含 `jdk.jfr`**（该包是 JDK **8u262+** 的 backport）。而 `spring-core` 的 `org.springframework.core.metrics.jfr` 包依赖 `jdk.jfr.*`，因此 `--release 8` 会编译失败（`程序包 jdk.jfr 不存在`）。

真实 JDK 8u262+ toolchain **一箭双雕**：既含 `jdk.jfr` backport 能编 JFR，又天然把 ByteBuffer 协变调用解析到 `java.nio.Buffer` 父类签名。这也是上游 Spring 用 `-PmainToolchain=8` 的原因。

## 修复方式

`Makefile` 各编译 main 的目标统一注入：

```makefile
TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11
```

- `-PmainToolchain=8`：main 源码用 JDK 8 编译（`gradle/toolchains.gradle` 已内置该开关）。
- `-PtestToolchain=11`：test 编译/运行仍用 JDK 11（test 依赖 JDK 9+ API，如 `InputStream.transferTo()`）。

**前提**：构建机需装 JDK 8（Gradle 经 SDKMAN! / 标准位置自动发现）。验证可发现：

```bash
./gradlew -q javaToolchains | grep -A2 "1.8"
```

## 发布后验收（字节码级）

```bash
javap -c -p spring-core/build/classes/java/main/org/springframework/core/io/buffer/DefaultDataBuffer.class \
  | grep -E 'ByteBuffer\.(clear|limit|position)'
```

- ❌ 有问题：描述符为 `…Ljava/nio/ByteBuffer;`（用 JDK 11 误编了 main）
- ✅ 正确：描述符为 `…Ljava/nio/Buffer;`（major 仍为 52）

运行时验证（JDK 8u472 实测）：加载修复后 `DefaultDataBuffer` 触发 `asByteBuffer()/slice()` 协变调用，正常返回、无 `NoSuchMethodError`。

## 相关

- OpenSpec change: `openspec/changes/fix-jdk8-bytebuffer-covariance/`
- toolchain 开关定义: `gradle/toolchains.gradle`
