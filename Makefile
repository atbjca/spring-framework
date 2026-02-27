.PHONY: clean install deploy build stop help

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make clean    - 清理构建产物"
	@echo "  make build-thin - 编译打包（不测试、无文档、不安装、不发布）"
	@echo "  make install  - 编译并安装到本地 Maven 仓库（~/.m2/repository）"
	@echo "  make deploy   - 发布到 Nexus 私服"
	@echo "  make stop     - 停止所有 Gradle Daemon"
	@echo "  make projects - 查看有效的项目"
	@echo "  make build    - 编译打包（全量）"
	@echo ""

clean: ## 清理构建产物
	./gradlew clean

build: clean ## 编译打包
	./gradlew build

build-thin: clean ## 编译打包（瘦身版）
	./gradlew build -x test -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc

install: clean ## 编译并安装到本地 Maven 仓库
	./gradlew publishToMavenLocal -x test

deploy: clean ## 发布到 Nexus 私服
	./gradlew publish -x test

stop: ## 停止所有 Gradle Daemon
	./gradlew --stop

projects: ## 查看有效的项目
	./gradlew projects
