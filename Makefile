.PHONY: clean install deploy build stop help setup-gradle checkstyle format

# Gradle 本地发行包配置脚本路径
SETUP_GRADLE := ./scripts/setup-gradle-local.sh

# 用真实 JDK 8 toolchain 编译 main，保证字节码与 JDK 8 运行时二进制兼容：
#   - ByteBuffer 协变返回方法（position/limit/clear/flip）解析到 java.nio.Buffer 父类签名，
#     避免 JDK 8 运行时 NoSuchMethodError（否则 DataBufferUtils 异步读会静默挂起）；
#   - jdk.jfr（8u262+ backport）在真实 JDK 8 下可编译（--release 8 的历史 ct.sym 不含它）。
# test 仍用 JDK 11（依赖 JDK 9+ API，如 InputStream.transferTo()）。
# 需本机存在 JDK 8（Gradle 经 SDKMAN! 自动发现，如 8.0.472-amzn）。
TOOLCHAINS := -PmainToolchain=8 -PtestToolchain=11

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make setup-gradle - 安装并解压 ~/dev 下全部 gradle-*-zip 到 wrapper 缓存；缺包则回退联网下载"
	@echo "  make clean    - 清理构建产物"
	@echo "  make build-thin - 编译打包（不测试、无文档、不安装、不发布）"
	@echo "  make install    - 编译并安装到本地 Maven（跳过文档，速度快）"
	@echo "  make deploy     - 发布到 Nexus 私服（跳过文档，速度快）"
	@echo "  make docs       - 专门生成项目文档 (Javadoc/Dokka/Asciidoc)"
	@echo "  make stop       - 停止所有 Gradle Daemon"
	@echo "  make projects - 查看有效的项目"
	@echo "  make build    - 编译打包（全量）"
	@echo "  make checkstyle - 运行 checkstyle 代码风格检查"
	@echo "  make format   - 自动清理 Java 源文件行尾空格"
	@echo ""
	@echo "Gradle 本地配置："
	@echo "  默认扫描 ~/dev/gradle-*-{bin,all}.zip"
	@echo "  可通过 LOCAL_GRADLE_DIR=/path/to/zips make setup-gradle 指定其他目录"
	@echo ""

# 安装并解压 LOCAL_GRADLE_DIR 下全部 Gradle zip（默认 ~/dev）到 Gradle Wrapper 缓存
# -----------------------------------------------------------------------------
# setup-gradle：构建前预热 Gradle 发行包（几乎所有 target 的前置依赖）
#
# 为什么这么做：
#   Gradle Wrapper 首次运行会按 gradle-wrapper.properties 里的 distributionUrl
#   联网从 services.gradle.org 下载发行包。在内网/离线/弱网环境下这一步很慢或
#   直接失败。本 target 调用 scripts/setup-gradle-local.sh，把本地已备好的
#   gradle-*-{bin,all}.zip 按 Wrapper 的缓存命名规则（MD5(url)->base36）直接
#   复制解压到 ~/.gradle/wrapper/dists/，模拟“首次下载已完成”，从而免联网。
#   因为用的是官方 URL 算 hash，gradle-wrapper.properties 无需改成 file://。
#
# 从哪里找包：
#   默认扫描 LOCAL_GRADLE_DIR（缺省 ~/dev）下的 gradle-*-{bin,all}.zip。
#   可覆盖：LOCAL_GRADLE_DIR=/path/to/zips make <target>
#
# 会产生什么效果：
#   - 找到本地包：免网络注入 Wrapper 缓存，构建直接用本地发行包（幂等，已就绪则跳过）。
#   - 找不到本地包：不再中断构建，仅打印提示并以退出码 0 继续，交回 Gradle Wrapper
#     按官方 distributionUrl 联网下载。（旧行为是 exit 1 直接让 make 失败。）
#
# 注意：
#   “缺包回退联网下载”依赖能访问 services.gradle.org。若既无本地包又完全离线，
#   下载会在 Gradle 自身阶段失败——此时请补齐本地包或设置 LOCAL_GRADLE_DIR。
# -----------------------------------------------------------------------------
setup-gradle: ## 配置本地 Gradle 发行包（无需网络下载）
	LOCAL_GRADLE_DIR="$(LOCAL_GRADLE_DIR)" UNPACK=1 "$(SETUP_GRADLE)"

clean: setup-gradle ## 清理构建产物
	./gradlew clean

build: setup-gradle clean ## 编译打包（含 checkstyle + 测试）
	./gradlew build $(TOOLCHAINS)

build-thin: setup-gradle clean ## 编译打包（瘦身版）
	./gradlew build $(TOOLCHAINS) -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x asciidoctor -x javadoc

# 编译并安装到本地 Maven 仓库（跳过测试和耗时的文档生成）
install: setup-gradle
	./gradlew clean publishToMavenLocal $(TOOLCHAINS) -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoc -x asciidoctor -x asciidoctorPdf -x api

# 发布到 Nexus 私服（跳过测试和耗时的文档生成）
deploy: setup-gradle
	./gradlew clean publish $(TOOLCHAINS) -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoc -x asciidoctor -x asciidoctorPdf -x api

# 专门用于生成文档的命令（如果确实需要 API 文档时使用）
docs: setup-gradle clean
	./gradlew javadoc dokkaHtml asciidoctor

stop: ## 停止所有 Gradle Daemon
	./gradlew --stop

checkstyle: setup-gradle ## 运行 checkstyle 代码风格检查
	./gradlew checkstyleMain checkstyleTest -x test

format: ## 自动清理 Java 源文件行尾空格
	@echo "清理 trailing whitespace..."
	@find . -path ./build -prune -o -name '*.java' -print | xargs sed -i '' 's/[[:space:]]*$$//'
	@echo "完成。建议运行 make checkstyle 验证。"

projects: setup-gradle ## 查看有效的项目
	./gradlew projects
