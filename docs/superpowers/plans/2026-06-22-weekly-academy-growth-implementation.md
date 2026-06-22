# 每周学堂成长线 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不新增小游戏、后台任务或循环动画的条件下，加入学习收益递减、每周印记和成长事件。

**Architecture:** `WeeklyGrowth.swift` 作为纯领域层，提供可注入的日/周标识、收益规则、节点内容和奖励。`PetProfile` 持久化进度，`PetReducer` 接收含日期的事件；学堂卡和桌宠只读取 profile、派发事件。

**Tech Stack:** Swift 5.7、SwiftUI、Foundation Calendar、XCTest、Swift Package Manager。

---

## 文件结构

- Create: `Sources/MomoPetApp/Domain/WeeklyGrowth.swift` — 学习周期、收益、节点和阶段内容。
- Modify: `Sources/MomoPetApp/Domain/PetProfile.swift` — 存档字段、事件和 reducer。
- Create: `Sources/MomoPetApp/Academy/WeeklyGrowthCard.swift` — 学堂成长卡。
- Modify: `Sources/MomoPetApp/MomoPetApp.swift` — 课程事件和成长卡接入。
- Modify: `Sources/MomoPetApp/Desktop/DesktopPetFeedback.swift` — 书本提示。
- Modify: `Sources/MomoPetApp/Desktop/DesktopPetView.swift` — 一次性提示和持久化确认。
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift` — 结算、跨日/周、兼容和领取保护。
- Create: `Tests/MomoPetAppTests/WeeklyGrowthTests.swift` — 纯领域规则。
- Modify: `Tests/MomoPetAppTests/DesktopPetFeedbackTests.swift` — 提示映射。
- Modify: `PROJECT_STATUS.md` — 阶段验收。

### Task 1: 建立可测试的周成长领域

**Files:**
- Create: `Sources/MomoPetApp/Domain/WeeklyGrowth.swift`
- Create: `Tests/MomoPetAppTests/WeeklyGrowthTests.swift`

- [ ] **Step 1: 写失败测试**

```swift
func testStudyMultiplierUsesOneHundredSeventyAndFortyPercent() {
    XCTAssertEqual(WeeklyStudyRule.multiplier(forCompletedCourses: 0), 1.0)
    XCTAssertEqual(WeeklyStudyRule.multiplier(forCompletedCourses: 1), 0.7)
    XCTAssertEqual(WeeklyStudyRule.multiplier(forCompletedCourses: 2), 0.4)
    XCTAssertEqual(WeeklyStudyRule.scaled(8, completedCourses: 2), 3)
}

func testMilestoneContentChangesWithSchoolStage() {
    XCTAssertEqual(WeeklyGrowthMilestone.attentive.content(for: .kindergarten).rewardName, "认真小贴纸")
    XCTAssertEqual(WeeklyGrowthMilestone.attentive.content(for: .primarySchool).rewardName, "班级小贴纸")
}
```

- [ ] **Step 2: 运行失败测试**

Run: `DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter WeeklyGrowthTests`

Expected: FAIL，`WeeklyStudyRule` 与 `WeeklyGrowthMilestone` 尚未定义。

- [ ] **Step 3: 最小实现**

定义以下公开领域接口；所有六种“学段 × 节点”内容必须显式列出：

```swift
struct StudyPeriod: Codable, Equatable {
    let dayID: String
    let weekID: String
    static func current(calendar: Calendar = .current, date: Date = Date()) -> Self
}

enum WeeklyGrowthMilestone: String, Codable, CaseIterable, Hashable {
    case attentive, explorer, star
    var requiredStamps: Int
    func content(for stage: SchoolStage) -> WeeklyGrowthContent
}

enum WeeklyStudyRule {
    static func multiplier(forCompletedCourses count: Int) -> Double
    static func scaled(_ value: Int, completedCourses: Int) -> Int
}
```

`StudyPeriod.current` 使用 ISO8601 日历生成 `yyyy-MM-dd` 和 `YYYY-'W'ww`。`scaled` 使用向下取整，非零收益最低保留 1。

- [ ] **Step 4: 运行通过测试并提交**

Run: 同 Step 2。Expected: PASS。

```bash
git add Sources/MomoPetApp/Domain/WeeklyGrowth.swift Tests/MomoPetAppTests/WeeklyGrowthTests.swift
git commit -m "Add weekly study growth rules"
```

### Task 2: 持久化并结算带日期的课程

**Files:**
- Modify: `Sources/MomoPetApp/Domain/PetProfile.swift`
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`

- [ ] **Step 1: 写失败测试**

```swift
func testSecondCourseOnSameDayUsesSeventyPercentAndAddsStamp() {
    let period = StudyPeriod(dayID: "2026-06-22", weekID: "2026-W26")
    var profile = PetProfile()
    profile = PetReducer.reduce(.courseCompleted(.literacy, period: period), profile: profile)
    profile = PetReducer.reduce(.courseCompleted(.literacy, period: period), profile: profile)
    XCTAssertEqual(profile.intelligence.value, 13)
    XCTAssertEqual(profile.weeklyStudyStampCount, 2)
}

func testNewWeekResetsDailyAndWeeklyProgress() {
    let old = StudyPeriod(dayID: "2026-06-22", weekID: "2026-W26")
    let next = StudyPeriod(dayID: "2026-06-29", weekID: "2026-W27")
    var profile = PetProfile(lastStudyDay: old.dayID, studyCountOnLastStudyDay: 3, weeklyStudyStampCount: 6, weeklyGrowthWeekID: old.weekID, claimedWeeklyGrowthMilestones: [.attentive])
    profile = PetReducer.reduce(.courseCompleted(.jumping, period: next), profile: profile)
    XCTAssertEqual(profile.strength.value, 8)
    XCTAssertEqual(profile.weeklyStudyStampCount, 1)
    XCTAssertEqual(profile.claimedWeeklyGrowthMilestones, [])
}
```

- [ ] **Step 2: 运行失败测试**

Run: `DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter PetDomainTests`

Expected: FAIL，字段和带 `period` 的事件尚不存在。

- [ ] **Step 3: 实现存档字段与 reducer**

在 `PetProfile` 添加 `lastStudyDay`、`studyCountOnLastStudyDay`、`weeklyStudyStampCount`、`weeklyGrowthWeekID`、`claimedWeeklyGrowthMilestones`、`announcedWeeklyGrowthMilestones` 和 `weeklyGrowthJournal`；所有字段都用 `decodeIfPresent` 默认空值。把课程事件更新为：

```swift
case courseCompleted(Course, period: StudyPeriod)
case primaryCourseCompleted(PrimaryCourse, period: StudyPeriod)
case weeklyGrowthClaimed(WeeklyGrowthMilestone, period: StudyPeriod)
case weeklyGrowthPromptAcknowledged(WeeklyGrowthMilestone, period: StudyPeriod)
```

课程前先归一化：日期变更仅清零同日次数；周变更清零印记、领取集合、已提示集合和日记。课程结算既有属性、能量和阶段经验均走 `WeeklyStudyRule.scaled`；课程后次数加一、印记最多 10。领取节点要求同周、达到 3/6/10 门槛、尚未领取；成功后写奖励、属性和日记。错误学段、旧周或重复领取无副作用。

- [ ] **Step 4: 加入兼容与重复领取测试，运行通过并提交**

```swift
func testOldProfileJSONDecodesWithEmptyWeeklyGrowthProgress() throws {
    let data = #"{"hunger":{"value":80},"mood":{"value":80},"cleanliness":{"value":80},"energy":{"value":80}}"#.data(using: .utf8)!
    let profile = try JSONDecoder().decode(PetProfile.self, from: data)
    XCTAssertEqual(profile.weeklyStudyStampCount, 0)
    XCTAssertEqual(profile.claimedWeeklyGrowthMilestones, [])
}
```

Run: 同 Step 2。Expected: PASS。

```bash
git add Sources/MomoPetApp/Domain/PetProfile.swift Tests/MomoPetAppTests/PetDomainTests.swift
git commit -m "Add weekly academy progress persistence"
```

### Task 3: 学堂成长卡与课程接入

**Files:**
- Create: `Sources/MomoPetApp/Academy/WeeklyGrowthCard.swift`
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`

- [ ] **Step 1: 写失败的展示状态测试**

```swift
func testNextMilestoneFindsFirstUnclaimedUnlockedMilestone() {
    let profile = PetProfile(weeklyStudyStampCount: 6, claimedWeeklyGrowthMilestones: [.attentive])
    XCTAssertEqual(profile.nextWeeklyGrowthMilestone, .explorer)
}
```

- [ ] **Step 2: 实现辅助属性并通过测试**

```swift
var nextWeeklyGrowthMilestone: WeeklyGrowthMilestone? {
    WeeklyGrowthMilestone.allCases.first {
        weeklyStudyStampCount >= $0.requiredStamps && !claimedWeeklyGrowthMilestones.contains($0)
    }
}
```

Run: `DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter PetDomainTests`

- [ ] **Step 3: 创建 `WeeklyGrowthCard` 并接入课程**

卡片显示 `学习印记 x / 10`、三个节点的未解锁/可领取/已领取状态和下一节点。可领取按钮派发：

```swift
store.dispatch(.weeklyGrowthClaimed(milestone, period: .current()))
```

在 `AcademyView.courseRow` 后插入 `WeeklyGrowthCard()`；六个课程按钮分别派发：

```swift
store.dispatch(.courseCompleted(.literacy, period: .current()))
store.dispatch(.primaryCourseCompleted(.reading, period: .current()))
```

卡片使用静态 SwiftUI 布局，不使用 `Timer`、`Task.sleep` 或 `repeatForever`。

- [ ] **Step 4: 编译并提交**

Run: `DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift build --disable-sandbox`

Expected: `Build complete!`。

```bash
git add Sources/MomoPetApp/Academy/WeeklyGrowthCard.swift Sources/MomoPetApp/MomoPetApp.swift Tests/MomoPetAppTests/PetDomainTests.swift
git commit -m "Show weekly growth in academy"
```

### Task 4: 一次性桌宠提示、验收和同步

**Files:**
- Modify: `Sources/MomoPetApp/Desktop/DesktopPetFeedback.swift`
- Modify: `Sources/MomoPetApp/Desktop/DesktopPetView.swift`
- Modify: `Tests/MomoPetAppTests/DesktopPetFeedbackTests.swift`
- Modify: `PROJECT_STATUS.md`

- [ ] **Step 1: 写失败的提示映射测试**

```swift
func testWeeklyGrowthPromptUsesStudyFeedback() {
    let event = PetEvent.weeklyGrowthPromptAcknowledged(.attentive, period: .init(dayID: "2026-06-22", weekID: "2026-W26"))
    XCTAssertEqual(DesktopPetFeedback.forEvent(event), .study)
}
```

- [ ] **Step 2: 最小实现并运行桌宠测试**

添加 `.study`：使用 `.idle` 姿态、`book.closed.fill` 图标、1.2 秒静态显示且不改变 offset。桌宠仅在 `nextUnannouncedWeeklyGrowthMilestone` 存在且当前没有显式反馈时，先派发 `weeklyGrowthPromptAcknowledged` 再显示 `.study`；喂食、摸摸、休息优先。

Run: `DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter DesktopPetFeedbackTests`

- [ ] **Step 3: 完整验证与驾驶舱更新**

将 `PROJECT_STATUS.md` 记录为“学堂成长扩展已完成”，下一阶段改为“小屋与装扮”。

Run:

```bash
DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift build -c release --disable-sandbox
DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox
```

Expected: 发布构建完成，所有测试零失败。随后启动发布版、收起桌宠，活动监视器静置 60 秒；以此前 CPU 约 0.1%、闲置唤醒 0、GPU 0 为性能基线。若明显回升，先排查再进入下一阶段。

- [ ] **Step 4: 提交并推送**

```bash
git add Sources/MomoPetApp/Desktop/DesktopPetFeedback.swift Sources/MomoPetApp/Desktop/DesktopPetView.swift Tests/MomoPetAppTests/DesktopPetFeedbackTests.swift PROJECT_STATUS.md
git commit -m "Complete weekly academy growth loop"
git push origin main
```

## 计划自检

- 规格的收益递减、跨日/周、三个节点、阶段内容、奖励、日记、学堂卡、桌宠一次性提示、旧存档兼容和低资源约束，分别在任务 1–4 中有实现和验证步骤。
- 所有类型和事件命名一致：`StudyPeriod`、`WeeklyStudyRule`、`WeeklyGrowthMilestone`、`weeklyGrowthClaimed`、`weeklyGrowthPromptAcknowledged`。
- 不含占位符、模糊实现描述或未定义的后续步骤。
