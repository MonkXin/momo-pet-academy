# 自然陪伴动效 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让小白的 3D 主形象在学堂与紧凑模式中呈现与当前宠物状态一致的轻量自然动效。

**Architecture:** 将状态到动效的判断放进独立、纯 Swift 的 `PetMotionProfile`，以便单元测试。新增 `RabbitPortraitView` 统一渲染资源图、呼吸、眨眼和耳朵微动，`AcademyView` 只负责传入 `PetProfile`，避免两个面板各自维护状态逻辑。

**Tech Stack:** Swift 5.7、SwiftUI、XCTest、Swift Package Manager（macOS 13+）。

---

## File structure

- Create: `Sources/MomoPetApp/Presentation/PetMotionProfile.swift` — 纯状态映射与动效数值。
- Create: `Sources/MomoPetApp/Presentation/RabbitPortraitView.swift` — 共享的 3D 兔子展示组件。
- Modify: `Sources/MomoPetApp/MomoPetApp.swift` — 用共享组件替代 `rabbitCard` 内部的直接图片渲染。
- Create: `Tests/MomoPetAppTests/PetMotionProfileTests.swift` — 映射的行为测试。

### Task 1: 可测试的状态动效映射

**Files:**
- Create: `Tests/MomoPetAppTests/PetMotionProfileTests.swift`
- Create: `Sources/MomoPetApp/Presentation/PetMotionProfile.swift`

- [ ] **Step 1: 写入失败测试**

```swift
import XCTest
@testable import MomoPetApp

final class PetMotionProfileTests: XCTestCase {
    func testNappingUsesSlowerBreathingThanStudying() {
        XCTAssertGreaterThan(
            PetMotionProfile.forActivity(.napping).breathingDuration,
            PetMotionProfile.forActivity(.studying).breathingDuration
        )
    }

    func testHungryAndLonelyActivitiesHaveVisualEmphasis() {
        XCTAssertEqual(PetMotionProfile.forActivity(.hungry).emphasis, .needsCare)
        XCTAssertEqual(PetMotionProfile.forActivity(.lonely).emphasis, .affection)
    }
}
```

- [ ] **Step 2: 运行失败测试**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter PetMotionProfileTests
```

Expected: 编译失败，提示 `PetMotionProfile` 不在作用域。

- [ ] **Step 3: 实现最小映射**

```swift
import SwiftUI

enum PetMotionEmphasis: Equatable {
    case none
    case restful
    case needsCare
    case affection
}

struct PetMotionProfile: Equatable {
    let breathingDuration: Double
    let breathingScale: CGFloat
    let earAngle: Double
    let blinkInterval: Double
    let emphasis: PetMotionEmphasis

    static func forActivity(_ activity: PetActivity) -> Self {
        switch activity {
        case .studying: return .init(breathingDuration: 3.8, breathingScale: 1.012, earAngle: 1.0, blinkInterval: 6.0, emphasis: .none)
        case .hopping: return .init(breathingDuration: 2.8, breathingScale: 1.018, earAngle: 2.5, blinkInterval: 4.5, emphasis: .none)
        case .napping: return .init(breathingDuration: 5.2, breathingScale: 1.006, earAngle: 0, blinkInterval: 9.0, emphasis: .restful)
        case .hungry: return .init(breathingDuration: 3.2, breathingScale: 1.014, earAngle: -1.2, blinkInterval: 5.0, emphasis: .needsCare)
        case .lonely: return .init(breathingDuration: 3.0, breathingScale: 1.015, earAngle: 2.0, blinkInterval: 4.0, emphasis: .affection)
        }
    }
}
```

- [ ] **Step 4: 验证映射测试通过**

Run the command from Step 2. Expected: `PetMotionProfileTests` passes.

### Task 2: 共享兔子肖像组件

**Files:**
- Create: `Sources/MomoPetApp/Presentation/RabbitPortraitView.swift`
- Test: `Tests/MomoPetAppTests/PetMotionProfileTests.swift`

- [ ] **Step 1: 添加失败测试**

```swift
func testPortraitAccessibilityDescribesTheCurrentActivity() {
    XCTAssertEqual(
        RabbitPortraitCopy.accessibilityLabel(for: .napping),
        "小白的 3D 形象，当前：午睡中"
    )
}
```

- [ ] **Step 2: 运行测试并确认失败**

Run the command from Task 1 Step 2. Expected: 编译失败，提示 `RabbitPortraitCopy` 不在作用域。

- [ ] **Step 3: 创建 `RabbitPortraitView`**

```swift
import SwiftUI

enum RabbitPortraitCopy {
    static func accessibilityLabel(for activity: PetActivity) -> String {
        let description: String
        switch activity {
        case .studying: description = "认真学习中"
        case .hopping: description = "开心蹦跳中"
        case .napping: description = "午睡中"
        case .hungry: description = "肚子咕咕叫"
        case .lonely: description = "想要摸摸"
        }
        return "小白的 3D 形象，当前：\(description)"
    }
}

struct RabbitPortraitView: View {
    let profile: PetProfile
    let size: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false
    @State private var blinking = false

    private var motion: PetMotionProfile { .forActivity(PetActivity.current(for: profile)) }

    var body: some View {
        Image(PetVisualAsset.masterImageName, bundle: .module)
            .resizable()
            .scaledToFit()
            .scaleEffect(reduceMotion ? 1 : (breathing ? motion.breathingScale : 1))
            .overlay(blinkOverlay)
            .accessibilityLabel(RabbitPortraitCopy.accessibilityLabel(for: PetActivity.current(for: profile)))
            .onAppear { startMotionIfAllowed() }
    }
}
```

Implement `blinkOverlay` as a short opacity-only overlay and `startMotionIfAllowed()` with `withAnimation(.easeInOut(duration: motion.breathingDuration).repeatForever(autoreverses: true))`. Do not introduce a timer; trigger the one-off blink with `DispatchQueue.main.asyncAfter` and schedule the next interval only while the view is visible.

- [ ] **Step 4: 运行映射测试**

Run the command from Task 1 Step 2. Expected: all `PetMotionProfileTests` pass.

### Task 3: 接入学堂与紧凑桌宠模式

**Files:**
- Modify: `Sources/MomoPetApp/MomoPetApp.swift:106-131`
- Modify: `Sources/MomoPetApp/MomoPetApp.swift:5-8`
- Modify: `Sources/MomoPetApp/Presentation/RabbitPortraitView.swift`
- Test: `Tests/MomoPetAppTests/PetMotionProfileTests.swift`

- [ ] **Step 1: 添加失败测试**

```swift
func testGeneratedRabbitImageIsBundledForThePortrait() {
    XCTAssertNotNil(PetVisualAsset.masterImageURL)
}
```

- [ ] **Step 2: 运行测试并确认失败**

Run the command from Task 1 Step 2. Expected: 编译失败，提示 `masterImageURL` 不存在。

- [ ] **Step 3: 使用共享组件**

Replace the direct `Image(PetVisualAsset.masterImageName, bundle: .module)` block in `AcademyView.rabbitCard` with:

```swift
RabbitPortraitView(profile: store.profile, size: 235)
    .frame(width: 210, height: 235)
    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
```

Add this resource locator next to `PetVisualAsset` in `MomoPetApp.swift`:

```swift
static var masterImageURL: URL? {
    Bundle.module.url(forResource: masterImageName, withExtension: "png")
}
```

Render emphasis as a restrained `RoundedRectangle` stroke: amber for `.needsCare`, pink for `.affection`, and a low-opacity cool overlay for `.restful`. Keep it non-interactive and do not hide any existing text status.

- [ ] **Step 4: 完整验证**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox
```

Expected: build succeeds and all tests pass.

- [ ] **Step 5: 手动 macOS 冒烟检查**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift run --disable-sandbox
```

Expected: 学堂与“收起为桌宠”均展示同一 3D 兔子；静止时有轻微呼吸；系统开启“减少动态效果”时不连续缩放。

## Plan self-review

- Spec coverage: Task 1 覆盖活动到配置映射；Task 2 覆盖主图、呼吸、眨眼与无障碍；Task 3 覆盖共享接入、状态强调、减少动态效果和完整验证。
- Placeholder scan: 无 TBD、TODO 或未定义类型；`PetActivity`、`PetProfile` 和 `PetVisualAsset` 均为现有类型。
- Type consistency: `PetMotionProfile.forActivity(_:)`、`PetMotionEmphasis`、`RabbitPortraitCopy.accessibilityLabel(for:)`、`RabbitPortraitView(profile:size:)` 在所有任务中名称一致。
- Repository note: 当前工作目录不是 Git 仓库，实施时跳过提交步骤并在交付中说明。
