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
- [x] **漏洞修复流水线**: 已完成全部识别出的 CVE 漏洞排查与修复。
    - **CVE-2024-38816**: 已完成代码修复并创建 [CVE-2024-38816.md](./CVE/CVE-2024-38816.md)。
    - **CVE-2024-38820**: 已完成代码修复并创建 [CVE-2024-38820.md](./CVE/CVE-2024-38820.md)。
    - **CVE-2025-22233**: 已完成代码修复（引入 `PatternMatchUtils.simpleMatchIgnoreCase`）并创建 [CVE-2025-22233.md](./CVE/CVE-2025-22233.md)。
    - **CVE-2025-41249**: 已完成代码修复（`resolve()` → `toClass()`）并创建 [CVE-2025-41249.md](./CVE/CVE-2025-41249.md)。
    - **CVE-2025-41242**: 已完成代码修复（重构 `StringUtils.uriDecode`）并创建 [CVE-2025-41242.md](./CVE/CVE-2025-41242.md)。
    - **CVE-2016-1000027**: 已彻底删除 `remoting/httpinvoker` 风险组件源并创建 [CVE-2016-1000027.md](./CVE/CVE-2016-1000027.md)。
    - **CVE-2025-41234**: 经代码排查验证 5.3 分支免疫（不存在导致风险的 Q-Encoding 逻辑），已出具 [CVE-2025-41234.md](./CVE/CVE-2025-41234.md) 声明文档。
- [x] **新增漏洞修复流水线 (Phase 2)**: 已完成追加的 3 个安全漏洞修复与文档。
    - **CVE-2024-38819**: 已完成 (WebMvc.fn/WebFlux.fn 路径穿越二期 Bypass) -> [CVE-2024-38819.md](./CVE/CVE-2024-38819.md)。
    - **CVE-2024-38827**: 已完成 (Spring Security 授权绕过) -> [CVE-2024-38827.md](./CVE/CVE-2024-38827.md)。
    - **CVE-2024-38828**: 已完成 (Spring MVC `@RequestBody byte[]` DoS) -> [CVE-2024-38828.md](./CVE/CVE-2024-38828.md)。

## 4. 发布指南
发布前请确保 `gradle.properties` 中的版本号正确，并已配置有效的 Nexus 凭据。
- **发布范围**:
    - **部署组件**: 根项目 (`spring`)、BOM (`framework-bom`) 以及所有核心模块 (`spring-*`)。
    - **不部署组件**: 内部测试模块 (`integration-tests`) 已被显式排除，不会上传至私服。
- **配置实现**: 发布地址已全局化，所有子项目均会自动寻址到 Nexus 仓库。
