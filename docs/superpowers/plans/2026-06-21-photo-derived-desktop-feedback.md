# 照片复刻桌宠与温柔互动反馈 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the generic desktop rabbit with a photo-derived transparent likeness and add short, low-resource petting and feeding feedback without changing the academy progression system.

**Architecture:** Keep image selection and feedback mapping as pure, testable values. `DesktopPetView` will own only the transient overlay state and one cancellable cleanup task, dispatching the same existing `PetStore` actions as before. A photo-derived transparent idle asset is the required display resource; optional action poses safely fall back to idle.

**Tech Stack:** Swift 5.7, SwiftUI, AppKit, Swift Package Manager, XCTest, bundled PNG assets, built-in image generation.

---

## File structure

- Modify: `Sources/MomoPetApp/MomoPetApp.swift` — define asset roles and decode a requested role with deterministic fallback.
- Create: `Sources/MomoPetApp/Desktop/DesktopPetFeedback.swift` — pure action-to-overlay mapping, without UI dependencies.
- Modify: `Sources/MomoPetApp/Desktop/DesktopPetView.swift` — render the one-off overlay and coordinate its lifetime with existing gestures and menus.
- Add: `Sources/MomoPetApp/Resources/momo-rabbit-desktop-idle.png` — approved photo-derived transparent idle rabbit.
- Optionally add: `Sources/MomoPetApp/Resources/momo-rabbit-desktop-petted.png`, `Sources/MomoPetApp/Resources/momo-rabbit-desktop-fed.png` — same-character action poses; absent files must not break the app.
- Create: `Tests/MomoPetAppTests/DesktopPetFeedbackTests.swift` — unit tests for feedback mapping and timing.
- Modify: `Tests/MomoPetAppTests/PetVisualAssetTests.swift` — resource-role fallback and idle asset coverage.

### Task 1: Define feedback semantics with tests

**Files:**
- Create: `Tests/MomoPetAppTests/DesktopPetFeedbackTests.swift`
- Create: `Sources/MomoPetApp/Desktop/DesktopPetFeedback.swift`

- [ ] **Step 1: Write the failing feedback-mapping tests**

```swift
import XCTest
@testable import MomoPetApp

final class DesktopPetFeedbackTests: XCTestCase {
    func testPetActionShowsHeartFeedback() {
        XCTAssertEqual(DesktopPetFeedback.forAction(.petted), .heart)
    }

    func testFeedActionShowsCarrotFeedback() {
        XCTAssertEqual(DesktopPetFeedback.forAction(.fed), .carrot)
    }

    func testRestActionDoesNotShowTransientFeedback() {
        XCTAssertNil(DesktopPetFeedback.forAction(.rested))
    }

    func testFeedbackHasShortFixedDurations() {
        XCTAssertEqual(DesktopPetFeedback.heart.duration, 0.8)
        XCTAssertEqual(DesktopPetFeedback.carrot.duration, 0.8)
    }
}
```

- [ ] **Step 2: Run the focused test and confirm compilation fails because the type does not exist**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter DesktopPetFeedbackTests
```

Expected: compilation error mentioning `DesktopPetFeedback`.

- [ ] **Step 3: Add the minimal pure mapping type**

```swift
import Foundation

enum DesktopPetFeedback: Equatable {
    case heart
    case carrot

    var duration: TimeInterval { 0.8 }

    static func forAction(_ action: PetEvent) -> Self? {
        switch action {
        case .petted: return .heart
        case .fed: return .carrot
        default: return nil
        }
    }
}
```

- [ ] **Step 4: Re-run the focused test and confirm it passes**

Run the command from Step 2. Expected: 4 tests pass.

- [ ] **Step 5: Commit the tested feedback mapping**

```bash
git add Sources/MomoPetApp/Desktop/DesktopPetFeedback.swift Tests/MomoPetAppTests/DesktopPetFeedbackTests.swift
git commit -m "Add desktop pet feedback mapping"
```

### Task 2: Add role-based photo asset selection with fallback

**Files:**
- Modify: `Tests/MomoPetAppTests/PetVisualAssetTests.swift`
- Modify: `Sources/MomoPetApp/MomoPetApp.swift`

- [ ] **Step 1: Write failing role and idle-resource tests**

Add to `PetVisualAssetTests`:

```swift
func testIdleDesktopPetAssetCanBeDecoded() {
    XCTAssertNotNil(PetVisualAsset.desktopPetImage(for: .idle))
}

func testMissingActionPoseFallsBackToIdleImage() {
    XCTAssertNotNil(PetVisualAsset.desktopPetImage(for: .petted))
    XCTAssertNotNil(PetVisualAsset.desktopPetImage(for: .fed))
}
```

- [ ] **Step 2: Run the focused asset tests and confirm they fail because the role API is absent**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter PetVisualAssetTests
```

Expected: compilation error mentioning `desktopPetImage(for:)` or `DesktopPetPose`.

- [ ] **Step 3: Implement exact role names and idle fallback**

Add alongside `PetVisualAsset`:

```swift
enum DesktopPetPose: String {
    case idle = "momo-rabbit-desktop-idle"
    case petted = "momo-rabbit-desktop-petted"
    case fed = "momo-rabbit-desktop-fed"
}
```

Replace the existing desktop image accessor with:

```swift
static func desktopPetImage(for pose: DesktopPetPose = .idle) -> NSImage? {
    let assetName = pose.rawValue
    let image = Bundle.module.url(forResource: assetName, withExtension: "png")
        .flatMap(NSImage.init(contentsOf:))
    if let image { return image }

    return Bundle.module.url(forResource: DesktopPetPose.idle.rawValue, withExtension: "png")
        .flatMap(NSImage.init(contentsOf:))
}
```

- [ ] **Step 4: Create and validate the photo-derived idle asset**

Use the supplied rabbit photographs as the character reference and generate one portrait with this locked brief:

> A highly realistic small white fluffy pet rabbit lying in a relaxed loaf pose, viewed from a slight front-left angle; one prominent black patch/ring surrounding its left eye, shiny dark eyes, round fluffy cheeks, a tiny pale pink nose, tall soft ears with pink inner fur, fine white whiskers. Match the specific rabbit reference, not a generic rabbit. Full body and paws visible, centered, transparent chroma-green background only (#00FF00), no ground, no cage, no props, no text, no border, natural soft studio light, 3D-rendered photographic detail.

Remove exactly `#00FF00` and near-green pixels into alpha using the existing chroma-key helper, export it as:

```
Sources/MomoPetApp/Resources/momo-rabbit-desktop-idle.png
```

Validate before replacing any visible resource:

```bash
sips -g pixelWidth -g pixelHeight -g hasAlpha Sources/MomoPetApp/Resources/momo-rabbit-desktop-idle.png
```

Expected: nonzero width/height and `hasAlpha: yes`.

- [ ] **Step 5: Re-run focused asset tests and confirm all pass**

Run the command from Step 2. Expected: all `PetVisualAssetTests` pass.

- [ ] **Step 6: Commit the role API and approved idle asset**

```bash
git add Sources/MomoPetApp/MomoPetApp.swift Sources/MomoPetApp/Resources/momo-rabbit-desktop-idle.png Tests/MomoPetAppTests/PetVisualAssetTests.swift
git commit -m "Use photo-derived idle desktop rabbit"
```

### Task 3: Render one feedback overlay without persistent work

**Files:**
- Modify: `Sources/MomoPetApp/Desktop/DesktopPetView.swift`
- Modify: `Tests/MomoPetAppTests/DesktopPetTapIntentTests.swift`

- [ ] **Step 1: Add the behavior-level regression test for double-tap precedence**

Add to `DesktopPetTapIntentTests`:

```swift
func testOnlySingleTapIsPetIntent() {
    XCTAssertEqual(DesktopPetTapIntent.forTapCount(1), .pet)
    XCTAssertEqual(DesktopPetTapIntent.forTapCount(2), .openAcademy)
}
```

- [ ] **Step 2: Run the focused gesture tests and confirm existing behavior is still green**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox --filter DesktopPetTapIntentTests
```

Expected: all gesture tests pass before UI integration.

- [ ] **Step 3: Add transient state and an overlay view**

In `DesktopPetView`, introduce these state properties:

```swift
@State private var feedback: DesktopPetFeedback?
@State private var clearFeedbackWorkItem: DispatchWorkItem?
```

Wrap the current image content in a `ZStack`, render the image with `PetVisualAsset.desktopPetImage(for: pose)`, and insert this overlay only when a feedback exists:

```swift
if let feedback {
    Text(feedback == .heart ? "♡" : "🥕")
        .font(.system(size: feedback == .heart ? 44 : 34))
        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
        .offset(y: feedback == .heart ? -70 : 36)
        .allowsHitTesting(false)
}
```

Add a `showFeedback(for:)` helper that cancels the existing work item, assigns the new feedback using `withAnimation`, and schedules exactly one `DispatchWorkItem` after `feedback.duration` to clear state using `withAnimation`. Add `onDisappear` to cancel the work item and clear feedback.

Update actions to preserve current behavior:

```swift
case .pet:
    store.dispatch(.petted)
    showFeedback(for: .petted)
case .openAcademy:
    openAcademy()
```

and context-menu buttons:

```swift
Button("喂食") {
    store.dispatch(.fed)
    showFeedback(for: .fed)
}
Button("休息") { store.dispatch(.rested) }
```

Use `.idle`, `.petted`, or `.fed` to select an action pose while the overlay is visible; the asset fallback from Task 2 makes missing optional action files safe.

- [ ] **Step 4: Run all unit tests and confirm they pass**

Run:

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache swift test --disable-sandbox
```

Expected: all tests pass with no new failures.

- [ ] **Step 5: Commit the desktop interaction overlay**

```bash
git add Sources/MomoPetApp/Desktop/DesktopPetView.swift Tests/MomoPetAppTests/DesktopPetTapIntentTests.swift
git commit -m "Add gentle desktop pet feedback"
```

### Task 4: Build, visual-verify, and measure idle behavior

**Files:**
- Modify: `README.md` only if the run instructions are inaccurate after verification.

- [ ] **Step 1: Run the full automated test suite**

Run the command from Task 3, Step 4. Expected: all XCTest cases pass.

- [ ] **Step 2: Launch the app locally**

```bash
cd "/Users/monkxin/Documents/桌面电子宠物"
DEVELOPER_DIR="/Users/monkxin/Downloads/Xcode.app/Contents/Developer" swift run
```

Expected: the academy window opens; selecting “收起为桌宠” shows the photo-derived transparent rabbit panel.

- [ ] **Step 3: Perform the manual interaction checklist**

Verify in order:

1. Drag the transparent rabbit and confirm it follows the pointer.
2. Single-click and confirm exactly one heart appears and disappears within one second.
3. Right-click, choose “喂食,” and confirm exactly one carrot appears and disappears within one second.
4. Double-click and confirm the academy opens with no heart flash.
5. Rapidly single-click ten times and confirm only one overlay is visible at a time and eventually clears.
6. Leave the panel untouched for 60 seconds; confirm it remains a static image without repeated motion.

- [ ] **Step 4: Measure idle CPU and memory on the user’s Mac**

Open Activity Monitor, select the running “MomoPetApp” process, wait 60 seconds after it is idle, and record CPU and Memory values. Acceptance is average CPU below 1%; investigate before continuing if RSS is above 120 MB.

- [ ] **Step 5: Commit any verified documentation correction and push when authorized**

```bash
git status --short
git add README.md
git commit -m "Document desktop pet verification"
git push origin main
```

Only commit `README.md` if it actually changed. Do not create an empty documentation commit.
