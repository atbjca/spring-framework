## 详细设计

### 1. 新增 `scripts/setup-gradle-local.sh`

**来源**: 从 `/Users/anan/Documents/GitHub/nes/spring-boot-3.5/scripts/setup-gradle-local.sh` 复制。

**核心逻辑**:
```bash
┌──────────────────────────────────────────────────────────────┐
│  输入: LOCAL_GRADLE_DIR (默认 ~/dev)                         │
│        GRADLE_USER_HOME (默认 ~/.gradle)                     │
│                                                              │
│  1. 扫描 ${LOCAL_GRADLE_DIR}/gradle-*-{bin,all}.zip          │
│  2. 对每个 zip:                                               │
│     a. 解析 version 和 dist_type (如 8.14.5, bin)            │
│     b. 计算 hash = MD5(https://services.gradle.org/.../gradle-X.zip) as base36 │
│     c. dest = ${GRADLE_USER_HOME}/wrapper/dists/gradle-X/<hash>/ │
│     d. 复制 zip → dest/gradle-X.zip                          │
│     e. unzip -q -o ... -d dest                               │
│     f. touch dest/gradle-X.zip.ok                            │
│  3. 如已就绪（*.ok 存在）则跳过                               │
└──────────────────────────────────────────────────────────────┘
```

**关键细节**:
- 使用 Python3 计算 MD5 hash（spring-boot-3.5 原样保留）
- `set -euo pipefail` — 任何步骤失败立即退出
- 支持 `UNPACK=0` 环境变量跳过解压（仅复制 zip）
- 跳过文件名不匹配 `gradle-*-{bin,all}.zip` 的文件

### 2. 统一 Gradle 版本

**文件**: `gradle/wrapper/gradle-wrapper.properties`

```properties
# 变更前
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.3-bin.zip

# 变更后
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.5-bin.zip
```

**理由**:
- `~/dev/gradle-8.14.5-bin.zip` 已存在
- `~/.gradle/wrapper/dists/gradle-8.14.5-bin/690y85m0j9nfaub7xoiayko8a/` 缓存已就绪
- 与 Makefile 原先引用的版本一致，避免人工再下载

### 3. 重构 Makefile

**文件**: `Makefile`

#### 3.1 删除直接二进制引用

```makefile
# 删除这些行：
GRADLE ?= $(HOME)/dev/gradle-8.14.5/bin/gradle
GRADLE_CMD := $(if $(wildcard $(GRADLE)),$(GRADLE),./gradlew)
```

#### 3.2 增加 setup-gradle 目标

```makefile
SETUP_GRADLE := ./scripts/setup-gradle-local.sh

.PHONY: setup-gradle
setup-gradle: ## 将本地 Gradle zip 安装到 wrapper 缓存
	@bash $(SETUP_GRADLE)
```

#### 3.3 所有构建命令依赖 setup-gradle

```makefile
# 变更前：
build-thin: ## 编译打包（跳过测试）
	$(GRADLE_CMD) clean build -x test $(GRADLE_ARGS)

# 变更后：
build-thin: setup-gradle ## 编译打包（跳过测试）
	./gradlew clean build -x test $(GRADLE_ARGS)
```

**受影响的 target**（均加 `setup-gradle` 依赖）:
- `test`
- `test-module`
- `clean`
- `stop`
- `projects`
- `build-thin`
- `install`
- `deploy`

#### 3.4 保留 JDK17 配置

`JDK17`、`GRADLE_ARGS`、`GRADLE_USER_HOME` 等保持不变。

#### 3.5 更新 help 输出

移除 `GRADLE=$(GRADLE_CMD)` 提示行，增加 `setup-gradle` 说明。

### 4. 文件变更汇总

| 文件 | 操作 | 说明 |
|------|------|------|
| `scripts/setup-gradle-local.sh` | 新增 | 从 spring-boot-3.5 复制 |
| `gradle/wrapper/gradle-wrapper.properties` | 修改 | 8.14.3 → 8.14.5 |
| `Makefile` | 修改 | 删除直接二进制、增加 setup-gradle 依赖 |

### 5. 验证步骤

```bash
# 1. 确认 wrapper 版本
grep distributionUrl gradle/wrapper/gradle-wrapper.properties
# 期望: gradle-8.14.5-bin.zip

# 2. 确认本地 zip 存在
ls ~/dev/gradle-8.14.5-bin.zip

# 3. 确认缓存（可选，setup-gradle 会自动处理）
ls ~/.gradle/wrapper/dists/gradle-8.14.5-bin/690y85m0j9nfaub7xoiayko8a/gradle-8.14.5/bin/gradle

# 4. 测试 make build-thin（会自动触发 setup-gradle）
make build-thin

# 5. 测试 make test
make test
```