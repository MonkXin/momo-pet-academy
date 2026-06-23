# 温馨小屋与装扮 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将已有奖励映射为固定位置家具与可见配饰，且不改变旧存档结构。

**Architecture:** 新增纯 `RoomRewardPresentation` 映射层；`RoomView` 以该映射渲染固定槽位，衣橱继续读取 `equippedAccessory`。只使用现有 `rewards` 和 `placedFurniture`。

### Task 1: 奖励映射与测试

- Create: `Sources/MomoPetApp/Academy/RoomRewardPresentation.swift`
- Create: `Tests/MomoPetAppTests/RoomRewardPresentationTests.swift`
- Write failing tests for 云朵绘本/星星奖牌/小阅读灯的位置类型，以及领结/徽章配饰类型。
- Implement mapping with explicit reward names and no default unknown visual.
- Run focused tests and commit.

### Task 2: 小屋固定槽位与衣橱显示

- Modify: `Sources/MomoPetApp/MomoPetApp.swift`
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`
- Render mapped furniture in room slots; distinguish 可摆放 and 已摆放; keep empty state.
- Add a lightweight accessory badge to the academy rabbit card.
- Run full tests and release build; commit and push.
