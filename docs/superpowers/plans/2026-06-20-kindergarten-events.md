# 幼儿园事件与奖励 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让课程经验解锁一次性幼儿园事件，并把奖励写入本地档案。

**Architecture:** 事件资格和结算留在 `PetReducer`；`PetProfile` 保存已完成事件和奖励集合；SwiftUI 面板只展示可领取事件并发出事件。

**Tech Stack:** Swift 5.7、SwiftUI、XCTest。

---

### Task 1: 领域事件

**Files:**
- Modify: `Sources/MomoPetApp/Domain/PetProfile.swift`
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`

- [ ] 写入失败测试：当档案有 10 XP 时，领取自我介绍应增加魅力、记录事件并加入蓝色领结。
- [ ] 运行 `swift test --disable-sandbox --filter PetDomainTests`，确认事件 API 缺失。
- [ ] 实现 `KindergartenEvent`、资格判断与领取 reducer。
- [ ] 重新运行测试并确认通过。

### Task 2: 学堂事件卡

**Files:**
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`

- [ ] 显示当前可领取事件、奖励文案和“领取”按钮。
- [ ] 按钮调用 `store.dispatch(.kindergartenEventClaimed(...))`。
- [ ] 运行完整测试：`swift test --disable-sandbox`。

