# 课程入口清晰度 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 让“今日课程”中的三张课程卡首次可见时即可被识别为上课入口。

**Architecture:** 只调整 `AcademyView` 的本地展示状态与 `CourseButton` 标签结构；课程仍派发既有日期化事件，不改变 reducer、存档或性能策略。

**Tech Stack:** SwiftUI、XCTest。

### Task 1: 课程卡文案与结果反馈

**Files:**
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`
- Modify: `Tests/MomoPetAppTests/PetDomainTests.swift`

- [ ] 为课程显示模型写测试，验证幼儿园课程有完整名称、属性收益和“点击上课”提示。
- [ ] 扩展 `CourseButton` 接收收益文案；卡片使用标题、收益、副提示三层文字，维持原色。
- [ ] 在 `AcademyView` 添加本地 `courseFeedback`；每个课程 action 在派发既有事件后更新文本为本次课程及印记提示。
- [ ] 将成长事件卡背景由白色高对比改为浅色低强调，领取按钮保持可见。
- [ ] 运行完整测试与发布构建，提交并推送。
