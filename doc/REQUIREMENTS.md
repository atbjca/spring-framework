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

## 3. 安全与合规
- [x] 配置项目全局 Group ID，支持通过 `gradle.properties` 一键修改。
- [x] 优化构建命令，默认跳过 `javadoc` 等耗时文档生成任务。
- [/] **漏洞修复流水线**: 正在按计划逐个修复识别出的 CVE 漏洞。
    - **CVE-2024-38816**: 已完成代码修复并创建 [CVE-2024-38816.md](./CVE/CVE-2024-38816.md)。

## 4. 发布指南
发布前请确保 `gradle.properties` 中的版本号正确，并已配置有效的 Nexus 凭据。
- **发布范围**:
    - **部署组件**: 根项目 (`spring`)、BOM (`framework-bom`) 以及所有核心模块 (`spring-*`)。
    - **不部署组件**: 内部测试模块 (`integration-tests`) 已被显式排除，不会上传至私服。
- **配置实现**: 发布地址已全局化，所有子项目均会自动寻址到 Nexus 仓库。
