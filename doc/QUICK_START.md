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

制品坐标示例：`cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1-SNAPSHOT`

## 4. 业务项目替换依赖

将 `org.springframework:spring-*` 换为 [GAV_MAPPING.md](GAV_MAPPING.md) 中的 NES 坐标；或使用 BOM：

```groovy
dependencyManagement {
    imports {
        mavenBom "cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT"
    }
}
```

**无需修改 Java import。**

## 5. 发布到 Nexus（可选）

见 [NEXUS_DEPLOY.md](NEXUS_DEPLOY.md)。配置 `~/.gradle/gradle.properties` 后：

```bash
make deploy
```
