# 业务需求说明 (REQUIREMENTS.md)

## 背景
我们fork并维护了一个官方已停止更新的老版本Spring Framework（基于5.3.39系列的spring-core、spring-web等模块），并已经在源码层面参照官方更高版本（5.3.x / 6.x）手动backport了已知CVE的修复补丁。计划长期自行维护并发布到公司内部Maven仓库（Nexus）。

## 面临问题
公司强制执行SCA扫描（依赖安全检查）。这些工具一旦识别出原始GAV（`org.springframework:spring-xxx`）或强特征，即使已经修补，也会报高危漏洞并阻断构建/发布流程。

## 目标
在**完全不修改任何Java源代码的package名、类名、类路径、导入语句**的前提下：
让这个自维护版本在主流SCA工具的扫描结果中尽量**不被判定为官方有漏洞的Spring组件**。

下游业务项目接受：
- 批量修改POM.xml 或 build.gradle 中的依赖坐标。

不能接受：
- 修改业务Java代码的import语句或类引用机制（破坏import兼容性）。

## 具体改动
- groupId 统一改为：`cn.bjca.footstone.bpring`
- artifactId 统一前缀：`bjca-footstone-bpring-` + 去掉原`spring-`前缀的首字母小写（例如：`spring-core` → `bjca-footstone-bpring-core`，`spring-framework-bom` → `bjca-footstone-bpring-framework-bom`）
- version：原版号 + `-nes.patch.N`（例如本次 RELEASE 为 `5.3.39-nes.patch.1`）

## 关键约束
1. 只涉及构建脚本GAV层面的修改，绝对保持Java层兼容性。
2. `SpringVersion.getVersion()` 获取到的版本号必须仍然是原始的 `5.3.39` 以确保框架内部校验不会因为版本号变更而出错。
