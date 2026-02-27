# Group ID 修改指南 (新手版)

你好！如果你想修改项目的 `group`（项目组标识符），现在非常简单。

## 如何修改？

1. **打开文件**: 寻找根目录下的 `gradle.properties` 文件。
2. **找到变量**: 寻找这一行：
   ```properties
   projectGroup=org.springframework
   ```
3. **进行修改**: 将等号后面的内容改为你想要的名称，例如：
   ```properties
   projectGroup=cn.bjca.footstone
   ```
4. **保存文件**: 保存后，Gradle 会在下次构建时自动应用这个新名称。

## 为什么这样做？

- **最小发动**: 你不需要去翻阅复杂的 `build.gradle` 代码，只需要修改这一个地方。
- **全局生效**: 这一处改动会影响到所有的子模块（如 `spring-core`, `spring-web` 等）。
- **什么是 Group ID**: 它通常代表你的组织或域名倒序。比如 `cn.bjca` 代表北京数字认证公司。修改它会改变发布出的 Jar 包的 Maven 坐标。

## 注意事项
- 修改后，如果你之前已经在本地仓库 (`~/.m2/repository`) 安装过旧版本的包，建议运行一次 `make clean` 以确保环境干净。
