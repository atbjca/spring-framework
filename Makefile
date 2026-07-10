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
	@echo "  make setup-gradle - 安装并解压 ~/dev 下全部 gradle-*-zip 到 wrapper 缓存"
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
setup-gradle: ## 配置本地 Gradle 发行包（无需网络下载）
	LOCAL_GRADLE_DIR="$(LOCAL_GRADLE_DIR)" UNPACK=1 "$(SETUP_GRADLE)"

clean: setup-gradle ## 清理构建产物
	JAVA_HOME=$$(awk '/^java/ {print $$2}' ~/.sdkman/candidates/java/11.0.30-tem/release 2>/dev/null || echo "/Users/anan/.sdkman/candidates/java/11.0.30-tem") ./gradlew clean

build: setup-gradle clean ## 编译打包（含 checkstyle + 测试）
	JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem ./gradlew build $(TOOLCHAINS)

build-thin: setup-gradle clean ## 编译打包（瘦身版）
	JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem ./gradlew build $(TOOLCHAINS) -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x asciidoctor -x javadoc

# 编译并安装到本地 Maven 仓库（跳过测试和耗时的文档生成）
install: setup-gradle
	JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem ./gradlew clean publishToMavenLocal $(TOOLCHAINS) -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoc -x asciidoctor -x asciidoctorPdf -x api

# 发布到 Nexus 私服（跳过测试和耗时的文档生成）
deploy: setup-gradle
	JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem ./gradlew clean publish $(TOOLCHAINS) -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoc -x asciidoctor -x asciidoctorPdf -x api

# 专门用于生成文档的命令（如果确实需要 API 文档时使用）
docs: setup-gradle clean
	JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem ./gradlew javadoc dokkaHtml asciidoctor

stop: ## 停止所有 Gradle Daemon
	./gradlew --stop

checkstyle: setup-gradle ## 运行 checkstyle 代码风格检查
	JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem ./gradlew checkstyleMain checkstyleTest -x test

format: ## 自动清理 Java 源文件行尾空格
	@echo "清理 trailing whitespace..."
	@find . -path ./build -prune -o -name '*.java' -print | xargs sed -i '' 's/[[:space:]]*$$//'
	@echo "完成。建议运行 make checkstyle 验证。"

projects: setup-gradle ## 查看有效的项目
	./gradlew projects
