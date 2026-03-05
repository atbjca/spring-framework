# GAV 映射表 (GAV_MAPPING.md)

以下列出了项目中所有 Spring 模块的基础GAV修改前后的映射关系，供业务侧进行全局替换时参考使用。

| 原始 GroupId | 原始 ArtifactId | 原始 Version | 替换后 GroupId | 替换后 ArtifactId | 替换后 Version |
| --- | --- | --- | --- | --- | --- |
| `org.springframework` | `spring-aop` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-aop` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-aspects` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-aspects` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-beans` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-beans` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-context` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-context` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-context-indexer` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-context-indexer` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-context-support` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-context-support` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-core` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-core` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-expression` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-expression` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-instrument` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-instrument` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-jcl` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-jcl` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-jdbc` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-jdbc` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-jms` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-jms` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-messaging` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-messaging` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-orm` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-orm` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-oxm` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-oxm` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-r2dbc` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-r2dbc` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-test` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-test` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-tx` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-tx` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-web` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-web` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-webflux` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-webflux` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-webmvc` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-webmvc` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-websocket` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-websocket` | `5.3.39-bjca-patched.1` |
| `org.springframework` | `spring-framework-bom` | `5.3.39` | `cn.bjca.footstone.bpring` | `bjca-footstone-bpring-framework-bom` | `5.3.39-bjca-patched.1` |

**使用说明**：
在下游项目的 `pom.xml` 或 `build.gradle` 中直接通过 `<dependencyManagement>`、`platforms` 结构批量替换坐标。本分支代码保留了全部原始 package 名 (`org.springframework.*`) 和所有自动装配机制的完整性，替换依赖后应用层无需修改任何 Java 导入语句。
