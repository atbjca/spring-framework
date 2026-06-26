# GroupId 修改指南

修改 NES 发布坐标时，优先改根目录 `gradle.properties`：

```properties
projectGroup=cn.bjca.footstone.bpring
version=6.2.19-nes.patch.1-SNAPSHOT
originalVersion=6.2.19
```

- **`projectGroup`**：所有 `spring-*` 模块与 `framework-bom` 的 GroupId（与 Boot NES 的 `forkGroupIdBase` 相同）。
- **`version`**：Maven 发布版本；发版时去掉 `-SNAPSHOT`。
- **`originalVersion`**：上游 Spring 基线；写入 JAR manifest，**不要**与 `version` 混用。

修改后建议：

```bash
make clean
make build-thin
```

若已 `make install` 过旧坐标，请清理 `~/.m2/repository/cn/bjca/footstone/bpring` 下对应版本目录。
