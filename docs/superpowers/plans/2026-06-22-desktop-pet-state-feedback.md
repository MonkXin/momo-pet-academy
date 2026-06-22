# 桌宠低干扰状态反馈 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Render fatigue, hunger, and affection needs as static-pose or one-time feedback without idle polling.

**Architecture:** A pure `DesktopPetStatePresentation` maps `PetActivity` to a pose and optional one-time feedback. `DesktopPetView` observes presentation changes and reuses its cancellable overlay.

**Tech Stack:** Swift, SwiftUI, XCTest.

---

### Task 1: State presentation mapping

**Files:** Create `Sources/MomoPetApp/Desktop/DesktopPetStatePresentation.swift`; create `Tests/MomoPetAppTests/DesktopPetStatePresentationTests.swift`.

- [ ] Write failing tests: napping maps to `.resting` with no prompt; hungry maps to `.idle` plus carrot; lonely maps to `.idle` plus heart; normal maps to `.idle` with no prompt.
- [ ] Run focused XCTest and confirm the missing type fails compilation.
- [ ] Implement the minimal `Equatable` presentation type and mapping from `PetActivity`.
- [ ] Re-run focused tests and commit.

### Task 2: Desktop integration

**Files:** Modify `Sources/MomoPetApp/Desktop/DesktopPetView.swift`; modify `Sources/MomoPetApp/MomoPetApp.swift`.

- [ ] Write a failing test for the new `.resting` pose resource selection.
- [ ] Add `.resting` to `DesktopPetPose` and connect `PetActivity.current(for:)` to the view presentation.
- [ ] Show the prompt only on presentation transition; keep explicit pet/feed feedback higher priority.
- [ ] Run all XCTest cases, commit, then conduct the user desktop checklist.
