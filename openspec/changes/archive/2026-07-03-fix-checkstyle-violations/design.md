## Context

本项目 fork 自 Spring Framework 5.3.39，配置了 Spring 官方的 checkstyle 规则。之前的 CVE backport 提交 `f06f78d935` 从高版本 Spring（6.2.x）移植代码时，带入了与 5.3.x checkstyle 规则不兼容的代码风格，导致 `make build` 全量构建失败（448 处违规，29 个文件）。

## Goals / Non-Goals

**Goals:**
- 修复全部 448 处 checkstyle 违规，使 `make build` 全量构建通过
- 在 Makefile 中新增 `checkstyle` 和 `format` 目标，方便后续检查和修复

**Non-Goals:**
- 不修改任何业务逻辑或功能代码
- 不修改 checkstyle 规则本身
- 不格式化未报错的文件

## Decisions

### 1. 按模块分批修复

按 Gradle 模块分组修复，每组独立验证。修复顺序按依赖关系：spring-core → spring-beans → spring-context → spring-expression → spring-jdbc → spring-jms → spring-test → spring-web → spring-webflux → spring-webmvc → spring-websocket → spring-context-support。

### 2. 修复策略

| 错误类型 | 修复方式 |
|---------|---------|
| RightCurly（206） | 将 `} else {` 拆成 `}\n else {`，`}` 独占一行 |
| Trailing whitespace（129） | 删除行尾空格 |
| SpringJavadoc（103） | 删除 Javadoc `@param`/`@return` 标签前的空行 |
| UnusedImports（7） | 删除无用 import 语句 |
| JavadocStyle（2） | 修复 Javadoc 格式 |
| ImportOrder（1） | 调整 import 顺序 |

### 3. Makefile 新增目标

- `checkstyle`: 运行 checkstyle 检查（不修复）
- `format`: 使用 `sed` 批量清理 trailing whitespace

## Risks / Trade-offs

- **Git diff 污染** → 全部是格式调整，使用独立 commit 隔离，不影响后续 CVE 修复的 diff 审查
- **合并冲突风险** → 这些文件短期内不会有功能修改，风险可控
