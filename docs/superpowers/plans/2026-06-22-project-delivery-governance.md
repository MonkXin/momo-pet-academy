# 项目驾驶舱与交付节奏治理 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a concise project-status dashboard that preserves the agreed development order, current phase, validated results, and deferred ideas across sessions.

**Architecture:** `PROJECT_STATUS.md` is the single operational entrypoint at the repository root; detailed specifications and implementation plans remain in `docs/superpowers/`. The dashboard contains only current state and links, so updating it does not duplicate design material or alter runtime code.

**Tech Stack:** Markdown, Git history, Swift Package Manager test output.

---

### Task 1: Create the project dashboard

**Files:**
- Create: `PROJECT_STATUS.md`

- [ ] **Step 1: Write the dashboard with one active phase and ordered next steps**

Create `PROJECT_STATUS.md` with these fixed sections and initial values:

```markdown
# 小白桌宠项目驾驶舱

## 当前阶段

**互动姿态与状态闭环（进行中）**

目标：为透明桌宠补齐摸摸、进食、休息姿态与低干扰状态提示，同时保持空闲静态、无轮询的低资源运行方式。

开始条件：透明、可拖动、始终在前的桌宠已经由用户桌面实测通过。

## 主线地图

1. 桌宠核心 — 已完成
2. 互动姿态与状态闭环 — 进行中
3. 小游戏体验闭环 — 待开始
4. 学堂成长扩展 — 待开始
5. 小屋与装扮 — 待开始
6. 发布、性能测量与开机体验 — 待开始

## 已验收成果

- 透明可拖动桌宠、双击回学堂、右键操作：用户已在 macOS 上确认。
- 照片复刻型凤眼兔趴姿与温柔互动：已合并到 `main`，自动测试 41 项通过；用户已确认基础运行正常。
- 空闲性能目标：无逐帧循环与轮询；仍待在 Activity Monitor / Instruments 记录 60 秒 CPU 与 RSS。

## 下一步

1. 为摸摸、进食、休息准备与待机兔一致的可选姿态资源，并保留待机资源回退。
2. 设计并实现饥饿、疲惫、想摸摸三种低干扰状态提示，不引入常驻动画。
3. 在用户 Mac 上完成连续互动与 60 秒空闲性能验收，记录 CPU 与 RSS。

## 停车场

- 完整可旋转 GLB 兔子模型：需要左右侧、背面照片或短环绕视频；在当前阶段完成后评估。
- 自动巡游、语音、跨应用识别：不属于当前低资源桌宠主线。

## 工作规则

- 开始任何开发前先阅读本文件；结束时更新当前阶段、验收结果和下一步。
- 同一阶段内自动完成测试、实现与小型修复；进入新阶段、改变视觉/玩法方向或改变性能取舍前必须取得用户确认。
- 新需求先判断是否服务当前阶段；不服务时写入停车场，除非用户明确要求重排主线。
- 未完成用户桌面验收或自动测试失败时，不进入下一阶段。
```

- [ ] **Step 2: Validate the dashboard shape**

Run:

```bash
rg -n "^## 当前阶段|^## 主线地图|^## 已验收成果|^## 下一步|^## 停车场|^## 工作规则" PROJECT_STATUS.md
```

Expected: exactly six matching section headings, and the file contains exactly one `（进行中）` marker.

- [ ] **Step 3: Confirm current state can be traced**

Run:

```bash
git log --oneline -5
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox
```

Expected: history includes the desktop-feedback commits and all XCTest cases pass.

- [ ] **Step 4: Commit the dashboard**

```bash
git add PROJECT_STATUS.md docs/superpowers/plans/2026-06-22-project-delivery-governance.md
git commit -m "Add project delivery dashboard"
```

### Task 2: Record the operational handoff

**Files:**
- Modify: `PROJECT_STATUS.md`

- [ ] **Step 1: Verify the dashboard is the first project-status reference**

Run:

```bash
sed -n '1,220p' PROJECT_STATUS.md
```

Expected: a developer joining with no chat context can identify the active phase, completed desktop-pet work, next three actions, deferred ideas, and entry/exit rules.

- [ ] **Step 2: Commit only if the verification found a necessary wording correction**

```bash
git status --short
git add PROJECT_STATUS.md
git commit -m "Clarify project dashboard handoff"
```

Do not create an empty commit when no correction is needed.
