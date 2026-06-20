# ADR-0002: MVP 改用 Python + tkinter

## Status

Accepted

## Context

当前 Mac 缺少完整 Xcode 和可用 macOS SDK，无法构建 SwiftUI 桌宠。产品仍需尽快实现透明悬浮、拖动、学堂、五项长期属性和本地存档。

## Decision

首版使用 Python 3 标准库：`tkinter` 负责桌宠与学堂窗口，`json` 负责本地档案，`unittest` 负责领域和存档测试。界面按模块与状态层分离，未来可保留同一领域模型迁移至 SwiftUI。

## Consequences

### Positive

- 不依赖 Xcode、第三方包或网络下载。
- 能在当前 Mac 直接运行，快速验证桌宠交互和长期养成。
- 存档与领域规则保持独立，迁移成本可控。

### Negative

- 首版视觉与窗口特效不如原生 SwiftUI 丰富。
- 需要在目标 macOS 上验证透明窗口的表现。

## Alternatives Considered

- **完整 Xcode + SwiftUI**：后续可作为正式 macOS 版本，当前环境不可用。
- **Electron/Tauri**：仍需要额外运行时和 macOS 构建配置，对 MVP 不划算。
- **浏览器页面**：开发快，但不满足真正桌面悬浮宠物的核心体验。

