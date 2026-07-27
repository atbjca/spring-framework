# 快速入门 (QUICK_START.md)

## 1. 环境

- JDK：**Amazon Corretto 17**（`sdk use java 17.0.17-amzn`）
- Gradle：`~/dev/gradle-8.14.5`（见 [TESTING.md](TESTING.md)）

## 2. 构建与测试

```bash
make help
make build-thin    # 编译打包（跳过测试，较快）
make test          # 全量测试
```

## 3. 安装到本地 Maven

```bash
make install
```

制品坐标示例：`cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1`

## 4. 业务项目替换依赖

将 `org.springframework:spring-*` 换为 [GAV_MAPPING.md](GAV_MAPPING.md) 中的 NES 坐标；或使用 BOM：

```groovy
dependencyManagement {
    imports {
        mavenBom "cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1"
    }
}
```

**无需修改 Java import。**

## 5. RELEASE 验证与发布

本组件没有内部 `cn.bjca.footstone` 前置依赖，也没有发布排除项。正式发布前复用能够关联到 release commit 祖先且未被中间源码变更失效的构建/测试证据，现场只执行：

```bash
make install
```

随后须扫描全部 Gradle publication POM 与 Maven Local POM，确认不存在内部 `-SNAPSHOT` 引用，并用仅含 `mavenLocal()` 的消费者验证 BOM 与代表制品。完整发布集共 26 个 GAV，其中还包括辅助坐标 `spring:framework-api:6.2.19-nes.patch.1` 与 `spring:framework-docs:6.2.19-nes.patch.1`。`Implementation-Version` 仍为上游基线 `6.2.19`。

见 [NEXUS_DEPLOY.md](NEXUS_DEPLOY.md)。配置 `~/.gradle/gradle.properties` 后：

```bash
make deploy
```

`make deploy` 发布到用户级 `nexusReleaseUrl` 指定的 RELEASE 仓库。RELEASE 制品不可覆盖；如出现部分发布，必须改用新的 NES patch 版本。
