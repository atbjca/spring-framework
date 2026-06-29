# CVE 批次评估报告（6.2.x Phase A → 核实关闭）

> 评估范围：影响 Spring Framework 6.2.x 的安全公告（含 5.3 NES 矩阵中的 2025–2026 批次）  
> 评估基线：`6.2.19-nes.patch.1-SNAPSHOT`  
> Phase A 日期：2026-06-26 | **核实关闭**：2026-06-29

## 1. 与 5.3 NES 矩阵的差异摘要

| 5.3 状态 | 6.2 状态 | 说明 |
|----------|----------|------|
| 已 backport（Phase 2） | 基线已集成 | 6.2.19 官方已含 2024 年多数修复 |
| 待修复 P0（41844/41853） | ✅ 上游已集成 | commit 已在 6.2.x 分支 |
| 待修复 P1（SpEL/WebSocket 等） | ✅ 上游已集成 | 见下表 |
| 待修复 P1（41254 STOMP） | ✅ **核实已集成** | `c88bfc54c9`（6.2.12+） |
| 待修复 P1（41842/41843） | ✅ **核实已集成** | `8d51f47357`（6.2.19） |

## 2. 优先级矩阵（6.2 终稿 — 2026-06-29 核实）

| CVE | 描述 | 分级 | 6.2 状态 | 官方 commit | 建议 |
|-----|------|------|----------|-------------|------|
| CVE-2025-41254 | STOMP CSRF | P1 | ✅ 已集成 | `c88bfc54c9` | 无需 action |
| CVE-2026-41842 | 版本化静态资源 DoS | P1 | ✅ 已集成 | `8d51f47357` | 无需 action |
| CVE-2026-41843 | 版本化静态资源路径穿越 | P1 | ✅ 已集成 | `8d51f47357` | 无需 action |
| CVE-2026-22737 | Script 视图路径 | P2 | ✅ 已集成 | `317a1f9909` | 无需 action |
| CVE-2026-22741 | 静态资源缓存投毒 | P2 | ✅ 已集成 | `e607f1c30f` | 无需 action |
| CVE-2026-22745 | Windows 静态资源 DoS | P2 | ✅ 已集成 | `684b1e8a4b` | 无需 action |
| CVE-2026-41844 | 开放重定向 | — | ✅ 已集成 | `3aaec98765` | 无需 action |
| CVE-2026-41853 | Multipart 走私 | — | ✅ 已集成 | `696692f1` | 无需 action |
| CVE-2026-41841 | 缓存碰撞 | — | ✅ 已集成 | `46867fad81` | 无需 action |
| CVE-2026-41838–41852 等 | 见 VULNERABILITY_FIXES | — | ✅ 已集成 | 见该文档 | 无需 action |

## 3. 核实方法（2026-06-29 spike）

### 共同步骤

1. `git branch --contains <commit>` 确认修复 commit 在 `6.2.x-bjca-patch`
2. 代码路径抽查（见 `openspec/changes/6.2-cve-verification-closeout/design.md`）
3. 定向单元测试（exit 0）：
   - `ContentBasedVersionStrategyTests.removeVersionOnlyOnce`（webmvc + webflux）
   - `ResourceTests.isReadableChecksExistsFirst`（spring-core）
   - `StompSubProtocolHandlerTests`（spring-websocket）

### Phase A 误判说明

Phase A 将 41254、41842/41843 标为「待核实」，因仅检索 commit message 关键词，未确认 **6.2.19 release 已合并** 对应官方补丁。Spike 后全部关闭。

## 4. 豁免 / 范围外

| 条目 | 说明 |
|------|------|
| CVE-2025-41248 | Spring Security 专属 |
| CVE-2016-1000027 | 6.2 已移除 HttpInvoker |
| 5.3 Phase 2 九个 CVE | 6.2.19 基线已覆盖 |
| 5.3 仍缺的 P1/P2 | **属 5.3 NES 项目**，不在 6.2 fork 范围 |

## 5. 后续建议

1. **SCA 报告**：引用本评估 + NES GAV 作豁免依据
2. **5.3 NES**：若仍维护 5.3 线，需在 **5.3 仓库** 单独 backport（6.2 无需重复）
3. **新 CVE**：按 OpenSpec 流程新建 change 评估
