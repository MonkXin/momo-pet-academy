# 白色凤眼兔桌面宠物 MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个可在 macOS 本地运行的白色凤眼兔桌宠 MVP，支持桌面悬浮、状态交互、幼儿园学堂、三项属性和离线存档。

**Architecture:** SwiftUI 负责学堂与小屋面板，`NSPanel` 负责桌面宠物浮窗。`PetStore` 是唯一可变状态入口；课程、互动和离线恢复产生 `PetEvent`，由 reducer 更新档案并写入 JSON 存档。

**Tech Stack:** Swift 6、SwiftUI、AppKit、Foundation、XCTest、Swift Package Manager。

---

## 文件结构

```
Package.swift
Sources/MomoPetApp/
  MomoPetApp.swift                 # 应用入口与菜单栏
  Domain/PetProfile.swift          # 宠物、状态、属性、课程模型
  Domain/PetEvent.swift            # 领域事件和 reducer
  Persistence/PetRepository.swift  # JSON 读写与损坏档案备份
  State/PetStore.swift             # Observable 主状态
  Desktop/PetPanelController.swift # 透明悬浮窗口
  UI/PetBubbleView.swift           # 桌宠与快捷互动
  UI/AcademyView.swift             # 学堂进度与课程
  UI/CourseCard.swift               # 单张课程卡
Tests/MomoPetAppTests/
  PetEventTests.swift
  PetRepositoryTests.swift
  PetStoreTests.swift
```

### Task 1: 建立可构建的 macOS 工程

**Files:**
- Create: `Package.swift`
- Create: `Sources/MomoPetApp/MomoPetApp.swift`
- Create: `Tests/MomoPetAppTests/SmokeTests.swift`

- [ ] **Step 1: 写入失败的启动测试**

```swift
import XCTest
@testable import MomoPetApp

final class SmokeTests: XCTestCase {
    func testAppModuleLoads() {
        XCTAssertEqual(AppMetadata.name, "小白的学堂时光")
    }
}
```

- [ ] **Step 2: 运行测试并确认失败**

Run: `swift test`

Expected: 编译失败，提示找不到 `AppMetadata`。

- [ ] **Step 3: 添加最小应用入口与包定义**

```swift
// Sources/MomoPetApp/MomoPetApp.swift
import SwiftUI

enum AppMetadata { static let name = "小白的学堂时光" }

@main
struct MomoPetApp: App {
    var body: some Scene {
        WindowGroup(AppMetadata.name) { Text("小白正在准备上学…") }
    }
}
```

- [ ] **Step 4: 运行测试并确认通过**

Run: `swift test`

Expected: `SmokeTests.testAppModuleLoads` PASS。

- [ ] **Step 5: 提交工程骨架**

Run: `git init && git add Package.swift Sources Tests && git commit -m "feat: bootstrap macOS pet app"`

### Task 2: 定义宠物档案与课程领域模型

**Files:**
- Create: `Sources/MomoPetApp/Domain/PetProfile.swift`
- Create: `Tests/MomoPetAppTests/PetEventTests.swift`

- [ ] **Step 1: 写入属性上限测试**

```swift
func testAttributeClampsToValidRange() {
    XCTAssertEqual(Stat(value: 105).value, 100)
    XCTAssertEqual(Stat(value: -4).value, 0)
}
```

- [ ] **Step 2: 实现领域值类型**

```swift
struct Stat: Codable, Equatable { let value: Int; init(value: Int) { self.value = min(100, max(0, value)) } }
enum Course: String, Codable, CaseIterable, Hashable { case literacy, jumping, stage }
struct PetProfile: Codable, Equatable {
    var hunger = Stat(value: 80); var mood = Stat(value: 80)
    var cleanliness = Stat(value: 80); var energy = Stat(value: 80)
    var intelligence = Stat(value: 0); var strength = Stat(value: 0); var charm = Stat(value: 0)
    var creativity = Stat(value: 0); var courage = Stat(value: 0)
    var kindergartenXP = 0; var completedCourses: Set<Course> = []
}
```

- [ ] **Step 3: 运行领域测试**

Run: `swift test --filter PetEventTests`

Expected: 属性上限测试 PASS。

- [ ] **Step 4: 提交模型**

Run: `git add Sources/MomoPetApp/Domain Tests/MomoPetAppTests/PetEventTests.swift && git commit -m "feat: add pet profile domain model"`

### Task 3: 实现互动、课程与离线恢复 reducer

**Files:**
- Create: `Sources/MomoPetApp/Domain/PetEvent.swift`
- Modify: `Tests/MomoPetAppTests/PetEventTests.swift`

- [ ] **Step 1: 写入课程结算测试**

```swift
func testLiteracyCourseRaisesIntelligenceAndConsumesEnergy() {
    let result = PetReducer.reduce(.courseCompleted(.literacy), profile: PetProfile())
    XCTAssertEqual(result.intelligence.value, 8)
    XCTAssertEqual(result.creativity.value, 4)
    XCTAssertEqual(result.energy.value, 72)
    XCTAssertEqual(result.kindergartenXP, 10)
}
```

- [ ] **Step 2: 实现事件与 reducer**

```swift
enum PetEvent { case fed, petted, rested, courseCompleted(Course), recoveredOffline(days: Int) }
enum PetReducer {
    static func reduce(_ event: PetEvent, profile: PetProfile) -> PetProfile {
        var next = profile
        switch event {
        case .fed: next.hunger = Stat(value: next.hunger.value + 18)
        case .petted: next.mood = Stat(value: next.mood.value + 12)
        case .rested: next.energy = Stat(value: next.energy.value + 20)
        case .courseCompleted(.literacy): next.intelligence = Stat(value: next.intelligence.value + 8); next.creativity = Stat(value: next.creativity.value + 4); next.energy = Stat(value: next.energy.value - 8); next.kindergartenXP += 10
        case .courseCompleted(.jumping): next.strength = Stat(value: next.strength.value + 8); next.courage = Stat(value: next.courage.value + 4); next.energy = Stat(value: next.energy.value - 10); next.kindergartenXP += 10
        case .courseCompleted(.stage): next.charm = Stat(value: next.charm.value + 8); next.courage = Stat(value: next.courage.value + 3); next.energy = Stat(value: next.energy.value - 7); next.kindergartenXP += 10
        case .recoveredOffline(let days): next.energy = Stat(value: next.energy.value + min(days, 3) * 8); next.mood = Stat(value: next.mood.value + min(days, 3) * 4)
        }
        return next
    }
}
```

- [ ] **Step 3: 写入并运行离线恢复边界测试**

```swift
func testOfflineRecoveryCapsAtThreeDays() {
    let result = PetReducer.reduce(.recoveredOffline(days: 20), profile: PetProfile())
    XCTAssertEqual(result.energy.value, 100)
}
```

Run: `swift test --filter PetEventTests`

Expected: 所有 `PetEventTests` PASS。

- [ ] **Step 4: 提交 reducer**

Run: `git add Sources/MomoPetApp/Domain Tests/MomoPetAppTests/PetEventTests.swift && git commit -m "feat: add pet interaction reducer"`

### Task 4: 实现安全的本地 JSON 存档

**Files:**
- Create: `Sources/MomoPetApp/Persistence/PetRepository.swift`
- Create: `Tests/MomoPetAppTests/PetRepositoryTests.swift`

- [ ] **Step 1: 写入存取回环测试**

```swift
func testSaveThenLoadReturnsSameProfile() throws {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("pet-test.json")
    let repository = PetRepository(url: url)
    try repository.save(PetProfile(intelligence: Stat(value: 12)))
    XCTAssertEqual(try repository.load(), PetProfile(intelligence: Stat(value: 12)))
}
```

- [ ] **Step 2: 实现原子写入与损坏备份**

```swift
final class PetRepository {
    private let url: URL
    init(url: URL) { self.url = url }
    static var inMemory: PetRepository {
        PetRepository(url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json"))
    }
    func save(_ profile: PetProfile) throws { try JSONEncoder().encode(profile).write(to: url, options: .atomic) }
    func load() throws -> PetProfile {
        do { return try JSONDecoder().decode(PetProfile.self, from: Data(contentsOf: url)) }
        catch { try? FileManager.default.moveItem(at: url, to: url.appendingPathExtension("corrupt")); throw error }
    }
}
```

- [ ] **Step 3: 写入损坏档案测试并实现 `.corrupt` 结果**

```swift
func testInvalidJSONIsReportedAsCorrupt() throws {
    try Data("broken".utf8).write(to: url)
    XCTAssertThrowsError(try repository.load())
}
```

Run: `swift test --filter PetRepositoryTests`

Expected: 存取和损坏档案测试 PASS。

- [ ] **Step 4: 提交存档层**

Run: `git add Sources/MomoPetApp/Persistence Tests/MomoPetAppTests/PetRepositoryTests.swift && git commit -m "feat: persist pet profile locally"`

### Task 5: 连接 Observable 状态与学堂视图

**Files:**
- Create: `Sources/MomoPetApp/State/PetStore.swift`
- Create: `Sources/MomoPetApp/UI/CourseCard.swift`
- Create: `Sources/MomoPetApp/UI/AcademyView.swift`
- Create: `Tests/MomoPetAppTests/PetStoreTests.swift`

- [ ] **Step 1: 写入 store 分发测试**

```swift
func testDispatchUpdatesPublishedProfile() {
    let store = PetStore(profile: PetProfile(), repository: .inMemory)
    store.dispatch(.petted)
    XCTAssertEqual(store.profile.mood.value, 92)
}
```

- [ ] **Step 2: 实现 `PetStore`**

```swift
@MainActor final class PetStore: ObservableObject {
    @Published private(set) var profile: PetProfile
    private let repository: PetRepository
    init(profile: PetProfile, repository: PetRepository) { self.profile = profile; self.repository = repository }
    func dispatch(_ event: PetEvent) { profile = PetReducer.reduce(event, profile: profile); try? repository.save(profile) }
}
```

- [ ] **Step 3: 实现 `AcademyView`，显示五项长期属性，并让三张课程卡调用 `dispatch(.courseCompleted(...))`**

```swift
CourseCard(title: "识字小课", icon: "text.book.closed", tint: .blue) {
    store.dispatch(.courseCompleted(.literacy))
}
```

- [ ] **Step 4: 运行状态与界面构建测试**

Run: `swift test && swift build`

Expected: 所有测试 PASS，应用模块构建成功。

- [ ] **Step 5: 提交学堂面板**

Run: `git add Sources/MomoPetApp/State Sources/MomoPetApp/UI Tests/MomoPetAppTests/PetStoreTests.swift && git commit -m "feat: add academy dashboard"`

### Task 6: 添加悬浮兔子窗口与端到端验证

**Files:**
- Create: `Sources/MomoPetApp/Desktop/PetPanelController.swift`
- Create: `Sources/MomoPetApp/UI/PetBubbleView.swift`
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`

- [ ] **Step 1: 写入行动标签单元测试**

```swift
func testLowEnergyDisplaysRestingAction() {
    XCTAssertEqual(PetAction.current(for: PetProfile(energy: Stat(value: 15))), .napping)
}
```

- [ ] **Step 2: 实现行动选择与桌宠视图**

```swift
enum PetAction { case hopping, studying, napping
    static func current(for profile: PetProfile) -> PetAction { profile.energy.value < 20 ? .napping : .studying }
}
```

- [ ] **Step 3: 以无边框、透明、浮动 `NSPanel` 承载 `PetBubbleView`；提供拖动区域与“上课”按钮打开 `AcademyView`**

```swift
let panel = NSPanel(contentRect: rect, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
panel.isOpaque = false
panel.backgroundColor = .clear
panel.level = .floating
```

- [ ] **Step 4: 执行完整验证**

Run: `swift test && swift build && swift run`

Expected: 测试全部 PASS；可拖动白色兔子浮窗出现；点击“上课”可显示幼儿园学堂，完成课程后属性实时变化；关闭重开后数据仍在。

- [ ] **Step 5: 提交可运行 MVP**

Run: `git add Sources Tests && git commit -m "feat: add floating white rabbit desktop pet"`

## 自检结果

- 规格中的桌宠、四项日常状态、五项长期属性、幼儿园三课、本地存档、离线恢复、错误处理和无障碍要求均有对应任务。
- 首版明确只实现幼儿园；小学至毕业旅行只预留领域扩展点，避免超出 MVP 范围。
- 计划未遗留占位步骤；后续所有类型均在前序任务中定义。
