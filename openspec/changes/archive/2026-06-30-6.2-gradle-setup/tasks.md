## 任务清单

### 任务 1: 创建 `scripts/setup-gradle-local.sh`

**操作**: 从 spring-boot-3.5 复制脚本到本项目

**源文件**: `/Users/anan/Documents/GitHub/nes/spring-boot-3.5/scripts/setup-gradle-local.sh`

**目标文件**: `scripts/setup-gradle-local.sh`

**执行方式**: 直接复制，内容无需修改（脚本本身已参数化，通过环境变量 `LOCAL_GRADLE_DIR` 和 `GRADLE_USER_HOME` 控制路径）

**验证**:
```bash
ls scripts/setup-gradle-local.sh
bash scripts/setup-gradle-local.sh  # 应输出 "已就绪: gradle-8.14.5-bin"
```

---

### 任务 2: 更新 `gradle/wrapper/gradle-wrapper.properties`

**操作**: 修改 `distributionUrl` 版本

**变更**:
```diff
- distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.3-bin.zip
+ distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.5-bin.zip
```

**验证**:
```bash
grep distributionUrl gradle/wrapper/gradle-wrapper.properties
# 应显示 8.14.5
```

---

### 任务 3: 重构 `Makefile`

**操作**: 删除直接二进制引用，增加 `setup-gradle` 目标，所有构建命令依赖它

**具体变更**:

1. **删除** `GRADLE ?= $(HOME)/dev/gradle-8.14.5/bin/gradle`
2. **删除** `GRADLE_CMD := $(if $(wildcard $(GRADLE)),$(GRADLE),./gradlew)`
3. **新增** `SETUP_GRADLE := ./scripts/setup-gradle-local.sh`
4. **新增** `.PHONY` 中的 `setup-gradle`
5. **新增** `setup-gradle` target
6. **修改** 所有构建 target（`test`, `test-module`, `clean`, `stop`, `projects`, `build-thin`, `install`, `deploy`）加上 `setup-gradle` 依赖
7. **替换** 所有 `$(GRADLE_CMD)` 为 `./gradlew`
8. **更新** help 输出（移除 `GRADLE=` 提示，增加 `setup-gradle` 说明）

**验证**:
```bash
# 确认 setup-gradle 存在
make setup-gradle

# 确认构建命令可用
make build-thin JDK17=~/.sdkman/candidates/java/17.0.17-amzn
```

---

### 任务 4: 本地验证

**操作**: 执行完整验证流程

```bash
# 清理后重新构建
make clean JDK17=~/.sdkman/candidates/java/17.0.17-amzn

# 确认 setup-gradle 被调用
make build-thin JDK17=~/.sdkman/candidates/java/17.0.17-amzn

# 运行测试（子集）
make test-module M=spring-core JDK17=~/.sdkman/candidates/java/17.0.17-amzn
```

**注意**: `make test` 全量测试耗时长（>30min），可根据时间决定是否执行

---

## 并行关系

- 任务 1 和任务 2 可并行执行
- 任务 3 依赖任务 1 完成（因为 Makefile 引用 `scripts/setup-gradle-local.sh`）
- 任务 4 依赖任务 1、2、3 全部完成

## 预计工时

- 任务 1: 5 分钟（复制文件）
- 任务 2: 2 分钟（一行修改）
- 任务 3: 15 分钟（Makefile 重构）
- 任务 4: 30-60 分钟（构建验证）
- **总计**: 约 50-80 分钟