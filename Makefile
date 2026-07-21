# Spring Framework 6.2 本地构建封装
# 使用 scripts/setup-gradle-local.sh 将本地 Gradle zip 安装到 ~/.gradle/wrapper/dists/
# 配合 sdkman 的 Amazon Corretto 17 执行构建

# setup-gradle-local.sh 路径（所有 make 命令依赖它确保环境就绪）
SETUP_GRADLE := ./scripts/setup-gradle-local.sh

# Amazon Corretto 17（与 buildSrc/JavaConventions 中 JvmVendorSpec.AMAZON 一致）
JDK17 ?= $(HOME)/.sdkman/candidates/java/17.0.17-amzn

# 传给 Gradle 的通用参数：注册本地 JDK、单进程构建（日志更直观）
GRADLE_ARGS := -Porg.gradle.java.installations.fromEnv=JDK17 --no-daemon

export JDK17

.PHONY: help setup-gradle check-jdk17 \
	test test-module clean stop projects build-thin install deploy

# 显示帮助信息
help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make setup-gradle  - 将本地 Gradle zip 安装到 wrapper 缓存（自动触发）；缺包则回退联网下载"
	@echo "  make build-thin    - 编译打包（跳过测试，较快）"
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
	@echo "  LOCAL_GRADLE_DIR=$(HOME)/dev  （Gradle zip 所在目录）"
	@echo "  GRADLE_USER_HOME=$(HOME)/.gradle"
	@echo "  （Gradle 缓存默认 ~/.gradle，Nexus 配置见 ~/.gradle/gradle.properties）"
	@echo ""

# 将本地 Gradle zip 安装到 ~/.gradle/wrapper/dists/（所有构建命令的前置依赖）
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
setup-gradle: ## 将本地 Gradle zip 安装到 wrapper 缓存
	@bash $(SETUP_GRADLE)

# 检查 JDK17 是否存在（供依赖此检查的目标使用）
check-jdk17:
	@test -d "$(JDK17)" || (echo "错误: JDK17 不存在: $(JDK17)"; exit 1)

# 全量测试
test: setup-gradle check-jdk17 ## 全量测试
	./gradlew test $(GRADLE_ARGS)

# 单模块测试：make test-module M=spring-core
test-module: setup-gradle check-jdk17 ## 测试单个模块（需指定 M=模块名）
	@test -n "$(M)" || (echo "用法: make test-module M=spring-core"; exit 1)
	./gradlew :$(M):test $(GRADLE_ARGS)

# 清理构建产物
clean: setup-gradle ## 清理构建产物
	./gradlew clean $(GRADLE_ARGS)

# 停止 Gradle Daemon
stop: ## 停止 Gradle Daemon
	./gradlew --stop

# 查看子项目列表
projects: setup-gradle ## 查看子项目列表
	./gradlew projects $(GRADLE_ARGS)

# 编译打包（跳过测试）
build-thin: setup-gradle check-jdk17 ## 编译打包（跳过测试）
	./gradlew clean build -x test $(GRADLE_ARGS)

# 安装到本地 Maven
install: setup-gradle check-jdk17 ## 安装到本地 Maven
	./gradlew clean publishToMavenLocal -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial $(GRADLE_ARGS)

# 发布到 Nexus
deploy: setup-gradle check-jdk17 ## 发布到 Nexus
	./gradlew clean publish -x test -x javadoc -x dokkaHtml -x dokkaHtmlPartial $(GRADLE_ARGS)