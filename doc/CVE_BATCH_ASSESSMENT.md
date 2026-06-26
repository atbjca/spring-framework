# CVE 批次评估报告（6.2.x Phase A）

> 评估范围：影响 Spring Framework 6.2.x 的安全公告（含 5.3 NES 矩阵中的 2025–2026 批次）  
> 评估基线：`6.2.19-nes.patch.1-SNAPSHOT`  
> 评估日期：2026-06-26

## 1. 与 5.3 NES 矩阵的差异摘要

| 5.3 状态 | 6.2 状态 | 说明 |
|----------|----------|------|
| 已 backport（Phase 2） | 基线已集成 | 6.2.19 官方已含 2024 年多数修复 |
| 待修复 P0（41844/41853） | ✅ 上游已集成 | commit 已在 6.2.x 分支 |
| 待修复 P1（SpEL/WebSocket 等） | 多数 ✅ 上游已集成 | 见下表 |
| 待修复 P1（41254 STOMP） | ⏳ 仍待核实 | 未见专用修复 |

## 2. 优先级矩阵（6.2 终稿）

| CVE | 描述 | 分级 | 6.2 状态 | 建议 |
|-----|------|------|----------|------|
| CVE-2025-41254 | STOMP CSRF | P1 | ⏳ 待核实 | 使用 STOMP 时建议 backport |
| CVE-2026-41842 | 版本化静态资源 DoS | P1 | ⏳ 待核实 | 部分 commit `8d51f47357`，需 spike |
| CVE-2026-41843 | 版本化静态资源路径穿越 | P1 | ⏳ 待核实 | 同上 |
| CVE-2026-22737 | Script 视图路径 | P2 | ⏳ 待核实 | 按是否使用 Script 视图 |
| CVE-2026-22741 | 静态资源缓存投毒 | P2 | ⏳ 待核实 | 低 CVSS，可延后 |
| CVE-2026-22745 | Windows 静态资源 DoS | P2 | ⏳ 待核实 | 非 Windows 可延后 |
| CVE-2026-41844 | 开放重定向 | — | ✅ 已集成 | 无需 action |
| CVE-2026-41853 | Multipart 走私 | — | ✅ 已集成 | 无需 action |
| CVE-2026-41841 | 缓存碰撞 | — | ✅ 已集成 | 无需 action |
| CVE-2026-41838–41852 等 | 见 VULNERABILITY_FIXES | — | ✅ 已集成 | 无需 action |

## 3. 待核实项说明

### CVE-2025-41254（STOMP CSRF）

- **模块**: `StompSubProtocolHandler`
- **判定**: 6.2 分支仅有状态管理重构（`c88bfc54c9`），**无明确 CSRF 防护 commit**
- **建议**: 若下游使用 STOMP over WebSocket，单独立项 backport

### CVE-2026-41842/41843

- **相关 commit**: `8d51f47357`（版本字符串移除策略）
- **判定**: 与 advisory 完整修复是否一致 **待 spike**
- **建议**: 对照官方 6.2.x security advisory 做 PoC 或测试移植

## 4. 豁免 / 范围外

| 条目 | 说明 |
|------|------|
| CVE-2025-41248 | Spring Security 专属 |
| CVE-2016-1000027 | 6.2 已移除 HttpInvoker |
| 5.3 Phase 2 九个 CVE | 6.2.19 基线已覆盖，无需重复 backport |

## 5. 后续建议

1. **OpenSpec + 审批**：CVE-2025-41254（若使用 STOMP）
2. **Spike**：41842/41843 与官方补丁 diff
3. **SCA 文档**：在扫描报告中引用本评估作豁免依据
