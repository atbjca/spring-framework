## 1. 实证与基线固定（修复前）

- [x] 1.1 记录修复前基线：`javap -c -p spring-core/build/classes/java/main/org/springframework/core/io/buffer/DefaultDataBuffer.class | grep 'ByteBuffer\.\(clear\|limit\|position\)'` —— 确认描述符为 `…Ljava/nio/ByteBuffer;`（实测 clear×6/limit×10/position×9，major 52）
- [x] 1.2 确认全爆炸半径（3 类）：`DefaultDataBuffer` / `ByteBufferDecoder`（flip）/ `UndertowServerHttpRequest$RequestBodyPublisher`（flip）—— 均为 `…Ljava/nio/ByteBuffer;`

## 2. 构建配置修复（方案 B：真 JDK 8 toolchain）

- [x] 2.1 ~~插件加 release~~（方案 A 已否决：与 `jdk.jfr` 冲突）→ 改为 `Makefile` 注入 `TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11`
- [x] 2.2 同时设 `-PtestToolchain=11`，保护 test 编译/运行仍在 JDK 11（避免被项目级 toolchain 拨到 JDK 8）
- [x] 2.3 针对性编译 `:spring-core:compileJava :spring-web:compileJava -PmainToolchain=8` 通过（含 `jdk.jfr` 包，BUILD SUCCESSFUL）

## 3. 字节码验收（修复后翻转）

- [x] 3.1 `DefaultDataBuffer.class`：`clear/limit/position` 描述符翻转为 `…Ljava/nio/Buffer;`，major 仍 52 ✅
- [x] 3.2 `ByteBufferDecoder.class` 的 `flip` → `…Ljava/nio/Buffer;` ✅
- [x] 3.3 `UndertowServerHttpRequest$RequestBodyPublisher.class` 的 `flip` → `…Ljava/nio/Buffer;` ✅
- [x] 3.4 零残留验证：全 spring-core+spring-web main 产物无任何协变 `…Ljava/nio/ByteBuffer;` 签名
- [x] 3.5 验证 test 未受影响：`compileTestJava` 用 JDK 11 编译通过（test 依赖 `InputStream.transferTo()` 等 JDK 9+ API）— BUILD SUCCESSFUL

## 4. 运行时验证（JDK 8）

- [x] 4.1 在真实 JDK 8u472 加载修复后 `DefaultDataBuffer`，触发 `asByteBuffer()/slice()` 协变调用 → 正常返回、无 `NoSuchMethodError`（`OK bytes=5 sliceCap=3 java.version=1.8.0_472`）
- [x] 4.2 对照组：JDK11 `-target 8` 无 `--release` 的协变产物在 JDK 8 上确实抛 `NoSuchMethodError: java.nio.ByteBuffer.position(I)Ljava/nio/ByteBuffer;`，反向坐实因果链

## 5. 文档与收尾

- [x] 5.1 新建 `doc/JDK8_COMPATIBILITY.md`：记录根因、为何用 toolchain 而非 --release、修复方式、验收命令
- [x] 5.2 checkstyle：本次零 Java 源码改动（仅 Makefile/doc/openspec，插件已还原），checkstyle（扫 `src/**/*.java`）不适用；`build-thin` 未触发新违规
- [x] 5.3 `make build-thin` 全量冒烟：**BUILD SUCCESSFUL in 4m 23s**，198 tasks，所有模块 main 在 JDK 8 toolchain 下编译通过（无其他 JDK 9+ API 地雷）
