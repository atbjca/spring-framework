## Why

`checkstyleNohttp` 检查失败，阻止构建通过：

```
doc/NEXUS_DEPLOY.md:6,7,8  → 内网 Nexus URL
openspec/changes/6.2-nes-nexus-deploy/design.md:8 → 内网 Nexus IP
```

内网 IP 地址暴露在文档中，也违反了 nohttp 规则（不允许 http:// URL）。

## What Changes

1. `doc/NEXUS_DEPLOY.md` 中的内网 URL 替换为 Gradle 属性占位符
2. `openspec/changes/6.2-nes-nexus-deploy/design.md` 中的同一 IP 替换为占位符

## Capabilities

### Modified Capabilities

- `nes-build-workflow`: 移除内网 IP 暴露，文档使用 `${NEXUS_xxx}` 占位符代替硬编码 URL

## Impact

- **文档**: `doc/NEXUS_DEPLOY.md`、`openspec/changes/6.2-nes-nexus-deploy/design.md`
- **不受影响**: Gradle 构建逻辑、Nexus 发布流程、`src/nohttp/allowlist.lines`
- **构建**: `make build-thin` / `make test` 不再因 http URL 违规失败

## Non-Goals

- 不修改 Gradle 构建逻辑或 Nexus 发布流程
- 不在 `allowlist.lines` 中添加 http URL 白名单（用占位符替代，无需白名单）

## 变更细节

```diff
# doc/NEXUS_DEPLOY.md
- nexusPublicUrl=${NEXUS_PUBLIC_URL}
- nexusReleaseUrl=${NEXUS_RELEASE_URL}
- nexusSnapshotUrl=${NEXUS_SNAPSHOT_URL}
+ nexusPublicUrl=${NEXUS_PUBLIC_URL}
+ nexusReleaseUrl=${NEXUS_RELEASE_URL}
+ nexusSnapshotUrl=${NEXUS_SNAPSHOT_URL}

# openspec/changes/6.2-nes-nexus-deploy/design.md
- | Nexus | `${NEXUS_URL}`（内网） |
+ | Nexus | `${NEXUS_URL}`（内网） |
```

**原理**: 替换后文档中不再包含 `http://` 字样，nohttp 检查不会被触发，无需修改 allowlist。