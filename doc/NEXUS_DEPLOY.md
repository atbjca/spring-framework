# Nexus 私服发布

凭证与仓库地址配置在 **`~/.gradle/gradle.properties`**（与 Spring Boot 2.7 NES 共用）。

```properties
nexusPublicUrl=http://192.168.131.36:8088/repository/maven-public/
nexusReleaseUrl=http://192.168.131.36:8088/repository/releases/
nexusSnapshotUrl=http://192.168.131.36:8088/repository/snapshots/
nexusUsername=developer
nexusPassword=***
```

## 发布命令

```bash
make deploy
```

当前 SNAPSHOT 版本 `6.2.19-nes.patch.1-SNAPSHOT` 将发布到 **snapshots** 仓库。

## 坐标示例

```
cn.bjca.footstone.bpring:bjca-footstone-bpring-core:6.2.19-nes.patch.1-SNAPSHOT
cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT
```
