## Context

fork 用 `make deploy`（JDK 11 `11.0.30-tem`）发布，但 `gradle/toolchains.gradle` 在未传 `-PmainToolchain=8` 时走 fallback，只设 `sourceCompatibility = 1.8`。这产生了「JDK 8 字节码版本 + JDK 9+ 协变签名」的错配产物，在 JDK 8 运行时崩溃。

### 编译四象限（问题定位）

| 编译单元 | -source/-target | bootclasspath(API) | 运行时 | 协变问题 |
|---|---|---|---|---|
| main (deploy) | 8（隐式） | JDK 11 ⚠️ | JDK 8 | **💥 崩** |
| test (build) | 8（隐式） | JDK 11 | JDK 11 | ✅ 不崩 |

关键区分：`-target 8` 只管**字节码版本**与语法层级，不管 API 边界；只有 `--release 8` 才把可见 API 锁到 JDK 8。这也解释了为何 test 现在能用 JDK 9+ API（如 `InputStream.transferTo()`）—— test 编译无 release，bootclasspath 仍是 JDK 11。

### 字节码实证（javap，非推断）

对现有产物 `spring-core/build/classes/java/main/.../DefaultDataBuffer.class`：

```
major version: 52                                  # = JDK 8 target，-target 8 已生效
java/nio/ByteBuffer.clear:()Ljava/nio/ByteBuffer;      # 协变签名，JDK 8 不存在
java/nio/ByteBuffer.limit:(I)Ljava/nio/ByteBuffer;
java/nio/ByteBuffer.position:(I)Ljava/nio/ByteBuffer;
```

`major 52 + …Ljava/nio/ByteBuffer;` 只可能由「JDK 9+ 编译器 + `-target 8` 无 `--release 8`」产生，与 MANIFEST `Created-By: 11.0.30` 咬合。

对照实验（同次编译，唯一变量=源码是否有 `(Buffer)` 转型）：

```
ByteBufferConverter:56   Buffer.rewind:()Ljava/nio/Buffer;       ✅ JDK 8 有（源码有 (Buffer) 转型）
ByteBufferDecoder:29     ByteBuffer.flip:()Ljava/nio/ByteBuffer;  💥 JDK 8 无（源码裸调用）
```

证明：`--release 8` 的效果 = 让所有协变调用点自动解析到 `Buffer` 父类签名，等价于「给每个点自动加 `(Buffer)` 转型」，零源码改动。

### 危害触发链

```
DataBufferUtils.readAsynchronousFileChannel
   └─ allocateBuffer() → DefaultDataBuffer（25 个协变调用点）
        AsynchronousFileChannel 完成回调线程执行
          → NoSuchMethodError（回调线程 Error 不传播回 failed()）
            → sink.next/complete 永不触发 → Mono.block() 永久死等
```

## Goals / Non-Goals

**Goals:**
- 修复 main 产物在 JDK 8 运行时的 `NoSuchMethodError`（协变返回类型错配）
- 覆盖 javap 实证的全部 3 类 27 处协变调用点
- 保持 test 编译不变（继续可用 JDK 9+ API）
- 与上游 CI `-PmainToolchain=8` 语义等价，但无需安装 JDK 8

**Non-Goals:**
- 不逐点改源码加 `(Buffer)` 转型（方案 C，易漏、与上游分叉）
- 不改测试编译/运行的 JDK 版本（test 仍用 JDK 11）
- 不重构 `DataBufferUtils` / `DefaultDataBuffer` 逻辑
- 不改动 `spring-core` 的 `jdk.jfr` 相关代码（靠真实 JDK 8 的 backport 编译）

## Decisions

### D1: 选方案 B（真 JDK 8 toolchain）—— 实现阶段从方案 A 修正

**背景修正**：初始 proposal 选方案 A（`options.release = 8`）。实现阶段针对性编译暴露致命冲突：`spring-core` 的 `org.springframework.core.metrics.jfr` 包依赖 `jdk.jfr.*`（Event/Label/Category/Description），而 `javac --release 8` 使用 JDK 11 内置的**历史 `ct.sym`**（JDK 8 最初 API 面），**不含 `jdk.jfr`（8u262+ 的 backport）** → `程序包 jdk.jfr 不存在`，编译失败。

**最小用例实证**（`JfrProbe.java`，同时含 `@Label` 与 `ByteBuffer.flip()`）：

| 编译方式 | jdk.jfr 可见 | `ByteBuffer.flip` 描述符 |
|---|---|---|
| JDK 11 `--release 8`（方案 A） | ❌ 程序包不存在 → 编不过 | — |
| 真实 JDK 8u472 `javac`（方案 B） | ✅ 可编 | `()Ljava/nio/Buffer;` ✅ |

**结论**：`--release 8` 比真实 JDK 8u472 **更严**（历史 ct.sym vs 含 backport 的真实运行时）。这正是上游 Spring 用 `-PmainToolchain=8`（真 JDK 8）而非 `--release 8` 的根本原因——真 JDK 8 一箭双雕：既能编 JFR，又天然产出 `Buffer` 父类描述符。

| 方案 | 动作 | 权衡 |
|---|---|---|
| **B（选定）** | deploy/build 传 `-PmainToolchain=8 -PtestToolchain=11` | 与上游 CI 设计一致；零源码改动；同时解决 ByteBuffer + JFR。需本机有 JDK 8 |
| A（已否决） | main 编译加 `options.release = 8` | 与 `jdk.jfr` 冲突，编不过 |
| A′ | release 8 + JFR 独立 source set | 保留无需 JDK8，但构建复杂、偏离上游 |
| C | 逐点 `((Buffer) buf)` 转型 | 治标、与上游分叉、无编译期护栏、绕不开需另处理 JFR |

**理由**: B 是 `gradle/toolchains.gradle` 文档里**明确设计**的用法（`-PmainToolchain=8 -PtestToolchain=11`），fork 只是 deploy 时漏传参数才掉进 fallback。本机已有 `8.0.472-amzn`，Gradle 经 SDKMAN! 自动发现。改动仅限 `Makefile`，零源码、零上游分叉。

### D2: 同时设 `-PtestToolchain=11`，保护 test 不被拨到 JDK 8

**选择**: 在会编译/运行 test 的 Makefile 目标（`build`）及跳过 test 的发布目标（`build-thin`/`install`/`deploy`）统一注入 `-PmainToolchain=8 -PtestToolchain=11`。

**理由**: `toolchains.gradle` 里 `-PmainToolchain=8` 会把项目级 Java toolchain 设为 JDK 8，若不显式指定 `testToolchain`，`testToolchainLanguageVersion()` 回退到 main 版本（=8），会波及 test 编译，破坏 test 对 JDK 9+ API（如 `InputStream.transferTo()`）的依赖。显式 `-PtestToolchain=11` 把 test 编译与运行拨回 JDK 11。对跳过 test 的目标，该参数为无害冗余（防御性）。

### D3: 只改 `Makefile`，不改 `toolchains.gradle` / `CompilerConventionsPlugin`

**选择**: 用 Makefile 变量 `TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11` 注入各目标；`gradle/toolchains.gradle` 与 `buildSrc` 插件保持原样。

**理由**: toolchain 分支逻辑上游已写好，缺的只是「调用时传参」。改 Makefile 最小、最贴近上游，且把「deploy 必须用 JDK 8 编 main」这一契约固化进发布入口，避免再次漏传。

## Risks / Trade-offs

- **[main 误用 JDK 9+ API 会编译期报错]** → 这是**预期收益**而非风险：等于给 JDK 8 兼容性上编译期护栏，远优于运行时 `NoSuchMethodError`。若确有 main 源码用了 JDK 9+ API，需在本次一并暴露并处理。
- **[Gradle 版本兼容]** → `JavaCompile.options.release`（`CompileOptions.getRelease()`）自 Gradle 6.6 起可用，本项目 Gradle 版本满足（`buildSrc` 已用 provider API）。实施时以 `make build-thin` 编译通过为准。
- **[test 被误伤]** → 由 D2 的任务名分流保证；验收时需确认 `compileTestJava` 无 release（`javap` test 产物仍可见 JDK 11 API 调用即证）。
- **[验收基线]** → 修复后 `DefaultDataBuffer.class` 的 `clear/limit/position` 描述符应从 `…Ljava/nio/ByteBuffer;` 翻转为 `…Ljava/nio/Buffer;`，major 仍为 52。
