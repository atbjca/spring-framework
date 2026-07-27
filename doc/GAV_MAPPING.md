# GAV 映射表 (GAV_MAPPING.md)

供下游在 `pom.xml` / `build.gradle` 中批量替换依赖坐标。Java 代码 **无需修改 import**。

| 原始 GroupId | 原始 ArtifactId | 原始 Version | 替换后 GroupId | 替换后 ArtifactId | 替换后 Version |
| --- | --- | --- | --- | --- | --- |
| `org.springframework` | `spring-aop` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-aop` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-aspects` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-aspects` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-beans` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-beans` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-context` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-context` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-context-indexer` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-context-indexer` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-context-support` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-context-support` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-core` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-core` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-core-test` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-core-test` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-expression` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-expression` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-instrument` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-instrument` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-jcl` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-jcl` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-jdbc` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-jdbc` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-jms` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-jms` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-messaging` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-messaging` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-orm` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-orm` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-oxm` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-oxm` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-r2dbc` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-r2dbc` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-test` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-test` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-tx` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-tx` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-web` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-web` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-webflux` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-webflux` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-webmvc` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-webmvc` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-websocket` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-websocket` | `6.2.19-nes.patch.1` |
| `org.springframework` | `spring-framework-bom` | `6.2.19` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-framework-bom` | `6.2.19-nes.patch.1` |

当前正式版本为 `6.2.19-nes.patch.1`。本组件没有内部 `cn.bjca.footstone` 前置 RELEASE，也没有发布排除项。开发阶段构建/测试证据经提交祖先和中间 diff 审核后复用；现场门禁为 `make install`、生成 POM 扫描和仅使用本地 RELEASE 制品的消费者验证。发布目标为用户级 `nexusReleaseUrl` 指定的 Nexus RELEASE 仓库。

所有替换后制品共享上表版本；JAR manifest 的 `Implementation-Version` 刻意保持上游基线 `6.2.19`。Nexus RELEASE 不可覆盖或重复发布。

`make install` / `make deploy` 还会生成两个不参与业务 GAV 替换的辅助 publication：

| GroupId | ArtifactId | Version | 内容 |
| --- | --- | --- | --- |
| `spring` | `framework-api` | `6.2.19-nes.patch.1` | 聚合 API 文档与 schema ZIP |
| `spring` | `framework-docs` | `6.2.19-nes.patch.1` | 文档 publication POM |

因此完整发布集为 23 个 NES 模块、1 个 BOM 和 2 个辅助 publication，共 26 个 GAV。

**BOM 示例（Gradle）：**

```groovy
dependencies {
    implementation platform("cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1")
    implementation "cn.bjca.footstone.bpring:bjca-footstone-bpring-context"
}
```
