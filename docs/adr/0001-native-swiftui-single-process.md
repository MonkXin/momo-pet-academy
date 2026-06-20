# ADR-0001: 使用原生 SwiftUI 单进程桌宠架构

## Status

Accepted

## Context

首版是仅运行在 macOS 上的离线桌面宠物，需要透明悬浮窗、菜单栏入口、低资源占用、本地存档，以及可逐步加入的小游戏和学堂成长系统。

## Decision

使用 Swift Package 构建 macOS 应用：SwiftUI 负责主界面和面板，AppKit 仅负责透明、悬浮、可拖动的宠物窗口。业务状态保存在单一 `PetStore`，通过 JSON 文件持久化；课程和小游戏只发送领域事件，不直接改写视图状态。

## Consequences

### Positive

- 原生支持 macOS 菜单栏、透明窗口和低功耗运行。
- 无账户、服务端、网络请求或云端成本。
- 状态、课程和存档有明确边界，后续可独立扩展小学至毕业旅行。

### Negative

- 首版仅支持 macOS。
- 透明悬浮与拖动行为需要少量 AppKit 代码。

## Alternatives Considered

- **Electron/Tauri**：跨平台更容易，但对首版不必要，且桌宠窗口与系统整合复杂度更高。
- **纯 AppKit**：窗口控制强，但 SwiftUI 更适合快速制作学堂、衣橱和成长日记界面。
- **服务端同步**：不符合单机与隐私优先的产品定位。

