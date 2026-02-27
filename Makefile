.PHONY: clean install deploy build stop help

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make clean    - 清理构建产物"
	@echo "  make build-thin - 编译打包（不测试、无文档、不安装、不发布）"
	@echo "  make install    - 编译并安装到本地 Maven（跳过文档，速度快）"
	@echo "  make deploy     - 发布到 Nexus 私服（跳过文档，速度快）"
	@echo "  make docs       - 专门生成项目文档 (Javadoc/Dokka/Asciidoc)"
	@echo "  make stop       - 停止所有 Gradle Daemon"
	@echo "  make projects - 查看有效的项目"
	@echo "  make build    - 编译打包（全量）"
	@echo ""

clean: ## 清理构建产物
	./gradlew clean

build: clean ## 编译打包
	./gradlew build

build-thin: clean ## 编译打包（瘦身版）
	./gradlew build -x test -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc

# 编译并安装到本地 Maven 仓库（跳过测试和耗时的文档生成）
install: 
	./gradlew clean publishToMavenLocal -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoctor -x asciidoctorPdf -x api

# 发布到 Nexus 私服（跳过测试和耗时的文档生成）
deploy:
	./gradlew clean publish -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial -x asciidoctor -x asciidoctorPdf -x api

# 专门用于生成文档的命令（如果确实需要 API 文档时使用）
docs: clean
	./gradlew javadoc dokkaHtml asciidoctor

stop: ## 停止所有 Gradle Daemon
	./gradlew --stop

projects: ## 查看有效的项目
	./gradlew projects
