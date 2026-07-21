## 1. Makefile 最小修复

- [x] 1.1 删除 `clean` recipe 中基于私有 SDKMAN 目录计算并覆盖 `JAVA_HOME` 的前缀，保留 `./gradlew clean`。
- [x] 1.2 删除 `build`、`build-thin`、`install`、`deploy`、`docs` 和 `checkstyle` recipe 中硬编码的 `JAVA_HOME=/Users/anan/.sdkman/candidates/java/11.0.30-tem` 前缀。
- [x] 1.3 核对所有 Gradle 任务、排除参数、目标前置依赖以及 `TOOLCHAINS` 参数与修改前一致。

## 2. 静态与命令展开验证

- [x] 2.1 搜索 `Makefile`，确认不再包含 `11.0.30-tem`、`/Users/anan` 或 recipe 级 `JAVA_HOME=` 赋值。
- [x] 2.2 使用 `make -n` 检查 `clean`、`build`、`build-thin`、`install`、`deploy`、`docs` 和 `checkstyle` 的命令展开，确认均直接调用 `./gradlew`，且原有参数保持不变。
- [x] 2.3 分别在有效 `JAVA_HOME` 和未设置 `JAVA_HOME` 的环境下检查 Wrapper Java 选择行为，确认 Makefile 不再注入备用路径。

## 3. 构建冒烟与范围确认

- [x] 3.1 在 Wrapper 发行包可用的环境运行 `make clean` 冒烟，确认不再出现 Makefile 注入的 `JAVA_HOME is set to an invalid directory` 错误。
- [x] 3.2 若冒烟被 `gradle-wrapper.properties` 的机器专属 `distributionUrl` 阻断，记录为既有独立问题，不在本变更中修改 Wrapper 或本地 Gradle 安装脚本。
- [x] 3.3 确认未新增 `test` Make 目标；记录 `make clean test` 的后续 `No rule to make target 'test'` 属于独立功能缺口。
- [x] 3.4 运行 OpenSpec 校验并复查最终 diff，确认应用代码只修改 `Makefile`，其余新增内容仅为本变更的 OpenSpec artifacts。
