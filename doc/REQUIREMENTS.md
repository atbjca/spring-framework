# 项目需求与配置说明 (REQUIREMENTS.md)

## 1. 基础设施要求

### 1.1 Gradle 配置
项目已集成 Nexus 私服支持及全局变量化管理，配置文件如下：
- `gradle.properties`: 维护项目版本 (`version`)、组 ID (`projectGroup`) 以及私服 URL 及凭据 (`nexusPublicUrl` 等)。
- `settings.gradle`: 在 `pluginManagement` 中集成私服仓库。
- `build.gradle`: 在 `allprojects` 和 `publishing` 块中配置私服仓库，并引用全局 `projectGroup`。

### 1.2 Makefile 快捷指令
为了简化开发流程，项目根目录提供了 `Makefile`，常用命令包括：
- `make build-thin`: 编译打包（排除测试和文档）。
- `make install`: 编译并安装到本地 Maven。**默认跳过文档生成**以优化速度。
- `make deploy`: 发布到 Nexus 私服。**默认跳过文档生成**。
- `make docs`: **专门用于生成项目文档** (Javadoc/Dokka/Asciidoc)。
- `make clean`: 清理构建产物。

## 2. 依赖管理
项目遵循 Spring 官方的依赖管理规范，通过 `io.spring.dependency-management` 插件进行版本控制。

## 3. 发布指南
发布前请确保 `gradle.properties` 中的版本号正确，并已配置有效的 Nexus 凭据。使用 `make deploy` 即可完成发布。
