# 小学第一学期 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为完成幼儿园毕业的小白提供小学课程、小学经验、班级事件、奖励和结业卡片。

**Architecture:** 继续使用 `PetProfile` + `PetReducer` 作为唯一游戏规则入口。小学专属经验和事件以独立字段保存；界面按 `schoolStage` 选择课程/事件数据，避免污染幼儿园数据。

**Tech Stack:** Swift 5.7、SwiftUI、XCTest、Swift Package Manager（macOS 13+）。

---

## File structure

- Modify: `Sources/MomoPetApp/Domain/PetProfile.swift` — 小学枚举、资料字段、兼容解码、Reducer。
- Modify: `Sources/MomoPetApp/MomoPetApp.swift` — 小学课程与事件卡片。
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift` — 小学规则与旧存档行为。

### Task 1: 小学进度与兼容存档

**Files:**
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`
- Modify: `Sources/MomoPetApp/Domain/PetProfile.swift`

- [ ] **Step 1: 写入失败测试**

```swift
func testPrimarySchoolCourseAddsPrimaryXPWithoutChangingKindergartenXP() {
    let profile = PetProfile(schoolStage: .primarySchool, kindergartenXP: 70)
    let result = PetReducer.reduce(.primaryCourseCompleted(.reading), profile: profile)
    XCTAssertEqual(result.primaryXP, 10)
    XCTAssertEqual(result.kindergartenXP, 70)
}

func testOldProfileJSONDecodesWithEmptyPrimaryProgress() throws {
    let data = #"{"hunger":{"value":80},"mood":{"value":80},"cleanliness":{"value":80},"energy":{"value":80}}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(PetProfile.self, from: data)
    XCTAssertEqual(result.primaryXP, 0)
    XCTAssertEqual(result.completedPrimaryEvents, [])
}
```

- [ ] **Step 2: 运行失败测试**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter PetDomainTests
```

Expected: 编译失败，提示 `primaryCourseCompleted`、`primaryXP` 或 `completedPrimaryEvents` 不存在。

- [ ] **Step 3: 添加数据结构与课程规则**

```swift
enum PrimaryCourse: String, Codable, CaseIterable { case reading, science, sportsClub }

enum PrimaryEvent: String, Codable, CaseIterable, Hashable {
    case introduction, carrotGarden, sportsDay, showcase
    var requiredXP: Int { switch self { case .introduction: return 30; case .carrotGarden: return 60; case .sportsDay: return 90; case .showcase: return 120 } }
}
```

Add `primaryXP: Int = 0` and `completedPrimaryEvents: Set<PrimaryEvent> = []` to `PetProfile`, its initializer, `CodingKeys`, and `decodeIfPresent` initializer. Add `case primaryCourseCompleted(PrimaryCourse)` and only apply it when `schoolStage == .primarySchool`:

```swift
case .primaryCourseCompleted(.reading):
    next.intelligence = next.intelligence.changed(by: 7); next.creativity = next.creativity.changed(by: 3); next.energy = next.energy.changed(by: -7); next.primaryXP += 10
case .primaryCourseCompleted(.science):
    next.intelligence = next.intelligence.changed(by: 5); next.courage = next.courage.changed(by: 4); next.energy = next.energy.changed(by: -8); next.primaryXP += 10
case .primaryCourseCompleted(.sportsClub):
    next.strength = next.strength.changed(by: 7); next.charm = next.charm.changed(by: 3); next.energy = next.energy.changed(by: -9); next.primaryXP += 10
```

- [ ] **Step 4: 验证测试通过**

Run the command from Step 2. Expected: all `PetDomainTests` pass.

### Task 2: 班级事件、奖励与结业条件

**Files:**
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`
- Modify: `Sources/MomoPetApp/Domain/PetProfile.swift`

- [ ] **Step 1: 写入失败测试**

```swift
func testPrimaryEventRequiresPrimarySchoolAndXPThenAwardsReward() {
    let base = PetProfile(schoolStage: .primarySchool, primaryXP: 30)
    let result = PetReducer.reduce(.primaryEventClaimed(.introduction), profile: base)
    XCTAssertTrue(result.completedPrimaryEvents.contains(.introduction))
    XCTAssertTrue(result.rewards.contains("小红领巾"))
    XCTAssertEqual(result.charm.value, 3)
}

func testPrimaryCompletionNeedsAllEventsAndOneHundredTwentyXP() {
    let profile = PetProfile(schoolStage: .primarySchool, primaryXP: 120, completedPrimaryEvents: Set(PrimaryEvent.allCases))
    XCTAssertTrue(profile.isPrimarySchoolComplete)
}
```

- [ ] **Step 2: 运行失败测试**

Run the command from Task 1 Step 2. Expected: 编译失败，提示小学事件或结业属性不存在。

- [ ] **Step 3: 实现事件领取**

Add `case primaryEventClaimed(PrimaryEvent)` and `isPrimarySchoolComplete`:

```swift
var isPrimarySchoolComplete: Bool {
    schoolStage == .primarySchool && primaryXP >= 120 && completedPrimaryEvents == Set(PrimaryEvent.allCases)
}
```

For `.primaryEventClaimed`, guard that the profile is in primary school, has enough `primaryXP`, and has not claimed the event. Apply: introduction `charm +3`, reward `小红领巾`; carrotGarden `creativity +3`, reward `花圃小徽章`; sportsDay `strength +3`, reward `运动水壶`; showcase `intelligence +3`, reward `云朵书包`.

- [ ] **Step 4: 验证测试通过**

Run the command from Task 1 Step 2. Expected: all `PetDomainTests` pass.

### Task 3: 让学堂按阶段显示小学内容

**Files:**
- Modify: `Sources/MomoPetApp/MomoPetApp.swift:58-82,154-187,241-260`
- Test: `Tests/MomoPetAppTests/PetDomainTests.swift`

- [ ] **Step 1: 添加失败测试**

```swift
func testPrimaryCourseIsIgnoredBeforeGraduation() {
    let result = PetReducer.reduce(.primaryCourseCompleted(.reading), profile: PetProfile())
    XCTAssertEqual(result.primaryXP, 0)
}
```

- [ ] **Step 2: 运行测试并确认失败**

Run the command from Task 1 Step 2. Expected: the event currently changes an ineligible profile or does not exist.

- [ ] **Step 3: 接入界面**

In `AcademyView`, replace the hard-coded course row with `courseRow`, branching on `store.profile.schoolStage`. Primary labels are `阅读课` / `科学观察` / `运动社团`, dispatching the three `PrimaryCourse` cases. Split `eventCard` into kindergarten and primary branches. Primary branch shows `小学经验：\(store.profile.primaryXP)` and the first claimable `PrimaryEvent`; when `isPrimarySchoolComplete`, show `小学结业啦！中学内容筹备中。`.

Extend the reward filtering in `RoomView`: exclude `蓝色领结` and `小红领巾` from furniture; both stay available to the existing wardrobe menu.

- [ ] **Step 4: 完整验证**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox
```

Expected: build succeeds and all tests pass.

## Plan self-review

- Spec coverage: Task 1 covers independent saved progress and old saves; Task 2 covers event gates, rewards and completion; Task 3 covers stage-specific UI and reward destinations.
- Placeholder scan: no incomplete tasks or undefined types.
- Type consistency: `PrimaryCourse`, `PrimaryEvent`, `primaryXP`, `completedPrimaryEvents`, `primaryCourseCompleted`, `primaryEventClaimed`, and `isPrimarySchoolComplete` use one name throughout.
- Repository note: this workspace is not a Git repository; implementation skips commit steps.
