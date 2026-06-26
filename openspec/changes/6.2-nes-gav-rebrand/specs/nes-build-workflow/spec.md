## ADDED Requirements

### Requirement: Make 构建入口

项目 MUST 提供 `Makefile`，封装本地 Gradle 与 JDK 环境，至少包含：

- `make test` — 全量测试
- `make build-thin` — 编译打包（跳过测试）
- `make install` — `publishToMavenLocal`
- `make deploy` — `publish`（需 `deploymentRepository`）

#### Scenario: 默认使用 Corretto 17

- **WHEN** 执行 `make test` 或 `make build-thin`
- **THEN** 使用 `JDK17` 环境变量指向的 Amazon Corretto 17，并传递 `-Porg.gradle.java.installations.fromEnv=JDK17`

#### Scenario: 缓存目录外置

- **WHEN** 未覆盖 `GRADLE_USER_HOME`
- **THEN** 默认使用 `~/Downloads/DELETE/tmp/gradle-home`，避免占满系统盘

### Requirement: 验证门禁

NES GAV change 实施完成后 MUST 通过以下验证方可合并：

1. `make build-thin` → BUILD SUCCESSFUL
2. `make test` → BUILD SUCCESSFUL（全量）

#### Scenario: build-thin 验证 manifest

- **WHEN** `make build-thin` 成功
- **THEN** `spring-core` JAR 的 `Implementation-Version` 为 `6.2.19`

### Requirement: 测试与构建文档

`doc/TESTING.md` MUST 描述测试环境、命令与 TDD 约定；`doc/QUICK_START.md` MUST 描述 `build-thin` / `install` 的最小使用路径。

#### Scenario: 新成员上手

- **WHEN** 阅读 `doc/QUICK_START.md`
- **THEN** 可在 5 分钟内完成 `make build-thin` 或 `make test` 的命令准备
