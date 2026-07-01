# CVE 批次评估报告（Phase A）

> 评估范围：2025-10 至 2026-06 披露、影响 Spring Framework 5.3.x 的安全公告  
> 评估基线：`5.3.x-bjca-patch`（基于 5.3.39）  
> 评估日期：2026-06-25

## 1. 优先级矩阵终稿

| CVE | 描述 | 分级 | 本分支状态 | 触发条件 | 建议 |
|-----|------|------|-----------|----------|------|
| CVE-2026-41844 | 开放重定向/内部转发 | **P0** | 受影响 | `/**` 映射 + 默认视图名推导 | 建议修复 |
| CVE-2026-41853 | Multipart 请求走私 | **P0** | 受影响 | 接受 multipart + 前置 WAF | 建议修复 |
| CVE-2025-41254 | STOMP CSRF | P1 | 受影响 | 使用 STOMP over WebSocket | 按模块修复 |
| CVE-2026-41838 | WebSocket Session ID 可预测 | P1 | 受影响 | 使用 spring-websocket | 按模块修复 |
| CVE-2026-41841 | CachingResourceResolver 缓存碰撞 | P1 | 受影响 | 启用静态资源缓存链 | 建议修复 |
| CVE-2026-41842 | 版本化静态资源 DoS | P1 | 受影响 | 使用 VersionResourceResolver | 建议修复 |
| CVE-2026-41843 | 版本化静态资源路径穿越 | P1 | 受影响 | 使用 VersionResourceResolver | 建议修复 |
| CVE-2026-41848 | SpEL ReDoS | P1 | 受影响 | 暴露用户可控 SpEL | 建议修复 |
| CVE-2026-41849 | SpEL 整数溢出 DoS | P1 | 受影响 | 暴露用户可控 SpEL | 建议修复 |
| CVE-2026-41850 | SpEL 算法复杂度 DoS | P1 | 受影响 | 暴露用户可控 SpEL | 建议修复 |
| CVE-2026-41851 | SpEL 模式缓存无限增长 | P1 | 受影响 | 暴露用户可控 SpEL | 建议修复 |
| CVE-2026-41852 | SpEL 受限上下文零参数调用 | P1 | 受影响 | 使用 SimpleEvaluationContext | 建议修复 |
| CVE-2026-41839 | WebFlux Session 固定 | P2 | 受影响 | 使用 WebFlux InMemoryWebSession | 按技术栈 |
| CVE-2026-41840 | WebFlux Multipart 内存泄漏 DoS | P2 | 受影响 | 使用 WebFlux multipart | 按技术栈 |
| CVE-2026-41845 | JavaScriptUtils XSS | P2 | 受影响 | 调用 `javaScriptEscape()` | 按技术栈 |
| CVE-2026-41846 | JSP 表单标签 XSS | P2 | 受影响 | 使用 Spring JSP 标签库 | 按技术栈 |
| CVE-2026-41855 | JMS Jackson 反序列化 | P2 | 受影响 | spring-jms + Jackson 转换器 | 按技术栈 |
| CVE-2026-22737 | Script 视图模板路径限制 | P2 | 受影响 | 使用 Script 视图 | 按技术栈 |
| CVE-2026-22740 | WebFlux Multipart 临时文件 DoS | P2 | 受影响 | WebFlux 大文件上传 | 按技术栈 |
| CVE-2026-22741 | 静态资源缓存投毒 | P2 | 受影响 | MVC/WebFlux 静态资源缓存 | 按技术栈 |
| CVE-2026-22745 | Windows 静态资源 DoS | P2 | 受影响 | Windows 部署 + 静态资源 | 低优先级 |

## 2. P1 批次适用性摘要

### CVE-2025-41254（STOMP CSRF）
- **模块**: spring-websocket (`StompSubProtocolHandler`)
- **影响版本**: 5.3.0 – 5.3.45（本分支 5.3.39 受影响）
- **修复版本**: 5.3.46（商业版）
- **判定**: 仅在使用 STOMP over WebSocket 时 relevant

### CVE-2026-41838（WebSocket Session ID）
- **模块**: spring-websocket
- **判定**: Session ID 非密码学安全随机，需结合授权策略评估风险

### CVE-2026-41841（CachingResourceResolver 缓存碰撞）
- **模块**: spring-webmvc / spring-webflux 静态资源链
- **判定**: 启用 `resourceChain(true)` 缓存时可能暴露受保护资源

### CVE-2026-41842/41843（版本化静态资源）
- **模块**: `VersionResourceResolver`（与 `ResourceHttpRequestHandler` 资源链配合）
- **判定**: 见第 3 节交叉验证——**与已有路径穿越补丁不重叠，需独立修复**

### CVE-2026-41848–41852（SpEL DoS 系列）
- **模块**: spring-expression
- **判定**: 5.3.39 已集成 CVE-2024-38808 基础 SpEL 限制，但 2026 年 SpEL 补丁系列为**额外加固**，不完全覆盖

## 3. 路径穿越补丁交叉验证（Task 1.5）

| 已有补丁 | 攻击面 | 修复位置 |
|----------|--------|----------|
| CVE-2024-38816 | Functional Web `PathResourceLookupFunction` + `FileSystemResource` | `PathResourceLookupFunction.java` |
| CVE-2024-38819 | 双重 URL 编码路径穿越 | `ResourceHttpRequestHandler.processPath/normalizePath` 等 |
| CVE-2025-41242 | `StringUtils#uriDecode` 非合规容器路径解码 | `StringUtils.java` |

| 新 CVE | 攻击面 | 与已有补丁关系 |
|--------|--------|----------------|
| CVE-2026-41842 | `VersionResourceResolver` 慢速解析 DoS | **不重叠** — 不同代码路径 |
| CVE-2026-41843 | `VersionResourceResolver` 路径穿越 | **不重叠** — 版本化资源解析逻辑独立 |

**结论**: 41842/41843 不能视为已被 38816/38819/41242 覆盖，需单独 backport。

## 4. P2 批次适用性摘要

| CVE | 关键点 | 暂缓条件 |
|-----|--------|----------|
| 41839 | WebFlux `InMemoryWebSession` 竞态 | 不使用 WebFlux |
| 41840 | WebFlux `PartGenerator` 内存泄漏 | 不使用 WebFlux multipart |
| 41845/41846 | XSS（JavaScriptUtils / JSP 标签） | 不使用对应 API |
| 41855 | JMS `MappingJackson2MessageConverter` 反序列化 | 不使用 spring-jms |
| 22737 | Script 视图模板路径 | 不使用 Script 视图 |
| 22740 | WebFlux multipart 临时文件 | 不使用 WebFlux |
| 22741 | 静态资源缓存投毒（低 CVSS 3.1） | 可延后 |
| 22745 | Windows 平台静态资源 DoS | 非 Windows 部署可延后 |

## 5. 豁免 / 范围外

| 条目 | 状态 | 说明 |
|------|------|------|
| CVE-2025-41234 | 天然免疫 | 5.3.x `ContentDisposition` 实现不受影响 |
| CVE-2025-41248 | 范围外 | Spring Security 专属，非本仓库 |
| CVE-2024-38808 等 5 个 | 基线已集成 | 5.3.39 自带，无需 backport |
| SpringVersion manifest | 有意设计 | 不按漏洞处理 |

## 6. 后续批次建议

1. **Phase B（需审批）**: CVE-2026-41844 + CVE-2026-41853
2. **Phase C（需审批）**: 按下游技术栈选择 P1 条目
3. **Phase D（需审批）**: P2 按模块裁剪
