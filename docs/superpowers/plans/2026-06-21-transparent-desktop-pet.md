# 透明常驻桌宠（P0）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让小白以透明、可拖动、低资源占用的独立 macOS 悬浮面板常驻桌面，并能回到学堂窗口。

**Architecture:** 新增纯逻辑的 `PetPosition` 与 `DesktopPetWindowController`，将 AppKit 面板生命周期从 SwiftUI 学堂视图中分离。`DesktopPetView` 只显示透明资源和手势；现有 `PetStore` 仍是唯一的养成状态来源。

**Tech Stack:** Swift 5.7、SwiftUI、AppKit、XCTest、Swift Package Manager（macOS 13+）。

---

## File structure

- Create: `Sources/MomoPetApp/Desktop/PetPosition.swift` — 可编码坐标、可见区域钳制。
- Create: `Sources/MomoPetApp/Desktop/DesktopPetView.swift` — 透明角色与单/双击手势。
- Create: `Sources/MomoPetApp/Desktop/DesktopPetWindowController.swift` — `NSPanel` 创建、显示、移动、持久化。
- Modify: `Sources/MomoPetApp/MomoPetApp.swift` — 学堂打开、关闭和桌宠切换入口。
- Modify: `Sources/MomoPetApp/Presentation/RabbitPortraitView.swift` — 支持透明资源优先加载。
- Create: `Tests/MomoPetAppTests/PetPositionTests.swift` — 位置与屏幕边界测试。
- Modify: `Tests/MomoPetAppTests/PetVisualAssetTests.swift` — 透明资源可解码测试。

### Task 1: 桌宠位置模型

**Files:**
- Create: `Tests/MomoPetAppTests/PetPositionTests.swift`
- Create: `Sources/MomoPetApp/Desktop/PetPosition.swift`

- [ ] **Step 1: 写入失败测试**

```swift
import XCTest
@testable import MomoPetApp

final class PetPositionTests: XCTestCase {
    func testPositionClampsInsideVisibleFrame() {
        let position = PetPosition(x: -20, y: 900)
        let result = position.clamped(in: PetFrame(x: 0, y: 0, width: 800, height: 600), petSize: PetSize(width: 260, height: 300))
        XCTAssertEqual(result, PetPosition(x: 0, y: 300))
    }
}
```

- [ ] **Step 2: 运行失败测试**

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter PetPositionTests
```

Expected: 编译失败，提示 `PetPosition` 不在作用域。

- [ ] **Step 3: 实现位置模型**

```swift
import Foundation

struct PetPosition: Codable, Equatable { let x: CGFloat; let y: CGFloat }
struct PetSize: Equatable { let width: CGFloat; let height: CGFloat }
struct PetFrame: Equatable { let x: CGFloat; let y: CGFloat; let width: CGFloat; let height: CGFloat }

extension PetPosition {
    func clamped(in frame: PetFrame, petSize: PetSize) -> Self {
        .init(x: min(max(x, frame.x), frame.x + max(0, frame.width - petSize.width)),
              y: min(max(y, frame.y), frame.y + max(0, frame.height - petSize.height)))
    }
}
```

- [ ] **Step 4: 验证通过**

Run the command from Step 2. Expected: `PetPositionTests` passes.

### Task 2: 透明角色资源与视图

**Files:**
- Modify: `Tests/MomoPetAppTests/PetVisualAssetTests.swift`
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`
- Create: `Sources/MomoPetApp/Desktop/DesktopPetView.swift`

- [ ] **Step 1: 写入失败测试**

```swift
func testDesktopPetImageCanBeDecoded() {
    XCTAssertNotNil(PetVisualAsset.desktopPetImage())
}
```

- [ ] **Step 2: 运行失败测试**

Run the command from Task 1 Step 2. Expected: 编译失败，提示 `desktopPetImage` 不存在。

- [ ] **Step 3: 添加透明资源与加载方法**

Add `momo-rabbit-desktop.png` to `Sources/MomoPetApp/Resources/`. Define `desktopPetImageName` and return `NSImage(contentsOf:)` from `desktopPetImage()`. The source must contain an alpha channel; do not reuse the warm-background academy artwork.

- [ ] **Step 4: 创建手势视图**

```swift
struct DesktopPetView: View {
    @ObservedObject var store: PetStore
    let openAcademy: () -> Void

    var body: some View {
        Image(nsImage: PetVisualAsset.desktopPetImage()!)
            .resizable().scaledToFit()
            .contentShape(Rectangle())
            .onTapGesture { store.dispatch(.petted) }
            .onTapGesture(count: 2) { openAcademy() }
    }
}
```

Attach `.contextMenu` with 喂食、休息、打开学堂、退出. The controller receives the quit closure so the view does not terminate the process directly.

- [ ] **Step 5: 验证资源测试**

Run the command from Task 1 Step 2. Expected: asset tests pass.

### Task 3: 独立透明 NSPanel

**Files:**
- Create: `Sources/MomoPetApp/Desktop/DesktopPetWindowController.swift`
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`
- Test: `Tests/MomoPetAppTests/PetPositionTests.swift`

- [ ] **Step 1: 添加失败测试**

```swift
func testDefaultPositionStartsAtTheDesktopCorner() {
    XCTAssertEqual(PetPosition.defaultPosition, PetPosition(x: 24, y: 48))
}
```

- [ ] **Step 2: 运行测试并确认失败**

Run the command from Task 1 Step 2. Expected: 编译失败，提示 `defaultPosition` 不存在。

- [ ] **Step 3: 实现控制器**

Add `static let defaultPosition = PetPosition(x: 24, y: 48)`. Create one borderless `NSPanel` with `.nonactivatingPanel`, clear background, `.floating` level, `.canJoinAllSpaces` and `.fullScreenAuxiliary` collection behavior. Save `panel.frame.origin` with `UserDefaults` after `windowDidMove`. Before restoration, clamp the stored `PetPosition` against `NSScreen.visibleFrame` through the model from Task 1. Do not add `Timer`, display link or polling.

- [ ] **Step 4: 连接应用入口**

Make `MomoPetApp` retain one `DesktopPetWindowController`. “收起为桌宠” hides the academy window and shows the panel. `openAcademy` hides the panel and activates the main window.

- [ ] **Step 5: 完整验证**

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox
```

Expected: build succeeds and all tests pass.

### Task 4: 性能与人工验收

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 添加开发测试说明**

Document a 60-second idle check: open desktop mode, leave the pointer still, use Activity Monitor or Instruments Time Profiler and Allocations, then record CPU average and RSS. State the P0 target as CPU below 1% on a typical idle Mac and RSS 120 MB as a warning threshold.

- [ ] **Step 2: 人工验收**

Launch with `swift run`, enter desktop mode, drag the pet, quit/relaunch, verify position recovery, double-click to return to academy, and enable Reduce Motion to confirm the view is static.

## Plan self-review

- Spec coverage: Tasks 1 and 3 cover position persistence; Task 2 covers transparent asset and gestures; Task 3 covers panel behavior; Task 4 covers resource constraints and measurements.
- Placeholder scan: no incomplete types or unnamed behaviors.
- Type consistency: `PetPosition`, `PetSize`, `PetFrame`, `DesktopPetView`, and `DesktopPetWindowController` are named consistently.
- Repository note: each completed task is committed and pushed using the configured SSH remote.
