## Why

之前 CVE backport 提交 `f06f78d935` 从上游高版本 Spring 移植代码时，引入了与本项目 checkstyle 规则不兼容的代码风格（RightCurly、trailing whitespace、SpringJavadoc 等）。`make build` 全量构建因 checkstyle 失败而无法通过，需修复以恢复 CI 完整性。

## What Changes

- 修复 29 个 Java 源文件中的 448 处 checkstyle 违规：
  - RightCurly（206 处）：`}` 未独占一行
  - Trailing whitespace（129 处）：行尾多余空格
  - SpringJavadoc（103 处）：Javadoc 标签前有空行
  - UnusedImports（7 处）：无用 import
  - JavadocStyle / ImportOrder（3 处）
- 在 Makefile 中新增 `checkstyle` 和 `format` 目标

## Capabilities

### New Capabilities
- `checkstyle-compliance`: 修复所有 checkstyle 违规，恢复 `make build` 全量构建通过

### Modified Capabilities

（无）

## Impact

- 涉及 6 个模块 29 个文件，全部为代码格式调整，无逻辑变更
- 受影响模块：spring-core、spring-beans、spring-expression、spring-jdbc、spring-jms、spring-context-support、spring-context、spring-test、spring-web、spring-webflux、spring-webmvc、spring-websocket
- Makefile 新增两个目标
