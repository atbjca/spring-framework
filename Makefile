# Spring Framework 6.2 本地构建封装
# 默认使用 ~/dev 下的 Gradle、sdkman 的 Amazon Corretto 17；Gradle 缓存使用 ~/.gradle

# 本地 Gradle（优先）；不存在时回退到项目 wrapper
GRADLE ?= $(HOME)/dev/gradle-8.14.5/bin/gradle
GRADLE_CMD := $(if $(wildcard $(GRADLE)),$(GRADLE),./gradlew)

# Amazon Corretto 17（与 buildSrc/JavaConventions 中 JvmVendorSpec.AMAZON 一致）
JDK17 ?= $(HOME)/.sdkman/candidates/java/17.0.17-amzn

# 传给 Gradle 的通用参数：注册本地 JDK、单进程构建（日志更直观）
GRADLE_ARGS := -Porg.gradle.java.installations.fromEnv=JDK17 --no-daemon

export JDK17

.PHONY: help test test-module clean stop projects build-thin install deploy

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make build-thin   - 编译打包（跳过测试，较快）"
	@echo "  make test          - 运行全项目单元/集成测试（gradle test）"
	@echo "  make test-module M=spring-core  - 仅测试指定模块，例如 spring-webmvc"
	@echo "  make install       - 安装到本地 Maven（~/.m2）"
	@echo "  make deploy        - 发布到 Nexus（凭证见 ~/.gradle/gradle.properties）"
	@echo "  make clean         - 清理构建产物"
	@echo "  make stop          - 停止 Gradle Daemon"
	@echo "  make projects      - 列出 Gradle 子项目"
	@echo ""
	@echo "环境变量（可覆盖）:"
	@echo "  JDK17=$(JDK17)"
	@echo "  GRADLE=$(GRADLE_CMD)"
	@echo "  （Gradle 缓存默认 ~/.gradle，Nexus 配置见 ~/.gradle/gradle.properties）"
	@echo ""

test: ## 全量测试
	@test -d "$(JDK17)" || (echo "错误: JDK17 不存在: $(JDK17)"; exit 1)
	$(GRADLE_CMD) test $(GRADLE_ARGS)

# 单模块测试：make test-module M=spring-core
test-module: ## 测试单个模块（需指定 M=模块名）
	@test -n "$(M)" || (echo "用法: make test-module M=spring-core"; exit 1)
	@test -d "$(JDK17)" || (echo "错误: JDK17 不存在: $(JDK17)"; exit 1)
	$(GRADLE_CMD) :$(M):test $(GRADLE_ARGS)

clean: ## 清理构建产物
	$(GRADLE_CMD) clean $(GRADLE_ARGS)

stop: ## 停止 Gradle Daemon
	$(GRADLE_CMD) --stop

projects: ## 查看子项目列表
	$(GRADLE_CMD) projects $(GRADLE_ARGS)

build-thin: ## 编译打包（跳过测试）
	@test -d "$(JDK17)" || (echo "错误: JDK17 不存在: $(JDK17)"; exit 1)
	$(GRADLE_CMD) clean build -x test $(GRADLE_ARGS)

install: ## 安装到本地 Maven
	@test -d "$(JDK17)" || (echo "错误: JDK17 不存在: $(JDK17)"; exit 1)
	$(GRADLE_CMD) clean publishToMavenLocal -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial $(GRADLE_ARGS)

deploy: ## 发布到 Nexus
	@test -d "$(JDK17)" || (echo "错误: JDK17 不存在: $(JDK17)"; exit 1)
	$(GRADLE_CMD) clean publish -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial $(GRADLE_ARGS)
