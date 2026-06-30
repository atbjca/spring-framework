## Why

当前 Makefile 的 Gradle 配置存在两个根本性问题：

1. **版本不一致**: Makefile 引用 `~/dev/gradle-8.14.5/bin/gradle`（二进制 8.14.5），而 `./gradlew` wrapper 使用 `gradle-wrapper.properties` 中的 8.14.3。两种机制并存，实际使用的版本不透明。

2. **缺少 setup-gradle 机制**: spring-boot-3.5 项目提供了 `scripts/setup-gradle-local.sh`，在构建前将本地 Gradle zip 安装到 `~/.gradle/wrapper/dists/` 缓存，实现完全离线构建。我们没有这个机制，依赖人工保证本地二进制存在。

3. **不符合团队规范**: 团队统一使用 `make` 命令构建，且希望采用与 spring-boot-3.5 一致的 `setup-gradle` 方式。

## What Changes

- 新增 `scripts/setup-gradle-local.sh`（从 spring-boot-3.5 复制，版本参数化）
- 统一 `gradle/wrapper/gradle-wrapper.properties` 中的 Gradle 版本为 8.14.5
- 重构 `Makefile`：移除直接二进制引用，增加 `setup-gradle` 目标，所有构建命令依赖它
- 删除 `GRADLE ?= ~/dev/gradle-8.14.5/bin/gradle` 这类直接二进制路径设定

## Capabilities

### New Capabilities

- `gradle-local-setup`: 通过本地 Gradle zip 预装到 wrapper 缓存，实现完全离线构建

### Modified Capabilities

- `nes-build-workflow`: `make build-thin` / `make test` 等命令统一通过 `./gradlew`（wrapper）+ `setup-gradle` 机制执行

## Impact

- **构建脚本**: `Makefile`（重构）、`scripts/setup-gradle-local.sh`（新增）、`gradle/wrapper/gradle-wrapper.properties`（版本统一）
- **本地环境**: 依赖 `~/dev/gradle-8.14.5-bin.zip` 存在（已有）
- **不受影响**: `build.gradle`、`settings.gradle`、Java 源码、文档
- **离线构建**: 完成后可在无网络环境下执行 `make build-thin` 等命令

## Non-Goals

- 不修改 Gradle wrapper 本身（`gradlew`/`gradlew.bat` 保持原样）
- 不引入新的 Gradle 插件或依赖
- 不修改 `~/.gradle/gradle.properties` 中的 Nexus 凭证配置
- 不处理 JDK 版本的变更（保持 JDK17）

## 与 spring-boot-3.5 对照

| 项 | spring-boot-3.5 | 6.2 本 change |
|----|----------------|---------------|
| setup-gradle 脚本 | `scripts/setup-gradle-local.sh` | 同 |
| LOCAL_GRADLE_DIR 默认值 | `~/dev` | `~/dev`（保持一致） |
| Gradle 版本 | 8.14.5-bin | 8.14.5-bin |
| wrapper 版本 | 8.14.5 | 8.14.5（统一） |
| 所有 make 命令依赖 setup-gradle | ✅ | ✅ |

## 实施后效果

```bash
# 首次使用（自动触发）
make build-thin
# → 自动调用 setup-gradle：将 ~/dev/gradle-8.14.5-bin.zip 安装到 ~/.gradle/wrapper/dists/
# → 使用 ./gradlew（wrapper 8.14.5）执行构建，完全离线

# 后续使用（已缓存）
make build-thin
# → 直接使用缓存的 Gradle 8.14.5，无需任何网络
```

## 变更前/后对比

```
变更前：
  GRADLE ?= ~/dev/gradle-8.14.5/bin/gradle    ← 直接二进制
  GRADLE_CMD := $(if $(wildcard $(GRADLE)),$(GRADLE),./gradlew)
  ./gradlew (wrapper 8.14.3)                  ← 版本不一致

变更后：
  ./gradlew (wrapper 8.14.5)                  ← 统一用 wrapper
  make build-thin → 先 setup-gradle → 再构建  ← 每次自动就绪
```