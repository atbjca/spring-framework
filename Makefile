.PHONY: clean install deploy build stop help setup-gradle

# Gradle 本地发行包配置脚本路径
SETUP_GRADLE := ./scripts/setup-gradle-local.sh

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
	@echo ""
	@echo "Gradle 本地配置："
	@echo "  默认扫描 ~/dev/gradle-*-{bin,all}.zip"
	@echo "  可通过 LOCAL_GRADLE_DIR=/path/to/zips make setup-gradle 指定其他目录"
	@echo ""

# 安装并解压 LOCAL_GRADLE_DIR 下全部 Gradle zip（默认 ~/dev）到 Gradle Wrapper 缓存
setup-gradle: ## 配置本地 Gradle 发行包（无需网络下载）
	LOCAL_GRADLE_DIR="$(LOCAL_GRADLE_DIR)" UNPACK=1 "$(SETUP_GRADLE)"

clean: setup-gradle ## 清理构建产物
	./gradlew clean

build: setup-gradle clean ## 编译打包
	./gradlew build

build-thin: setup-gradle clean ## 编译打包（瘦身版）
	./gradlew build -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x asciidoctor -x javadoc

# 编译并安装到本地 Maven 仓库（跳过测试和耗时的文档生成）
install: setup-gradle
	./gradlew clean publishToMavenLocal -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoc -x asciidoctor -x asciidoctorPdf -x api

# 发布到 Nexus 私服（跳过测试和耗时的文档生成）
deploy: setup-gradle
	./gradlew clean publish -x test -x checkstyleMain -x checkstyleTest -x checkstyleNohttp -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoc -x asciidoctor -x asciidoctorPdf -x api

# 专门用于生成文档的命令（如果确实需要 API 文档时使用）
docs: setup-gradle clean
	./gradlew javadoc dokkaHtml asciidoctor

stop: ## 停止所有 Gradle Daemon
	./gradlew --stop

projects: setup-gradle ## 查看有效的项目
	./gradlew projects
