import SwiftUI
import AppKit

enum AppMetadata {
    static let name = "小白的学堂时光"
}

enum DesktopPetPose: String {
    case idle = "momo-rabbit-desktop-idle"
    case petted = "momo-rabbit-desktop-petted"
    case fed = "momo-rabbit-desktop-fed"
    case resting = "momo-rabbit-desktop-resting"
}

enum PetVisualAsset {
    static let masterImageName = "momo-rabbit-3d"
    static let desktopPetImageName = "momo-rabbit-desktop"

    static var masterImageURL: URL? {
        Bundle.module.url(forResource: masterImageName, withExtension: "png")
    }

    static func masterImage() -> NSImage? {
        guard let masterImageURL else { return nil }
        return NSImage(contentsOf: masterImageURL)
    }

    static func desktopPetImage(for pose: DesktopPetPose = .idle) -> NSImage? {
        if let image = image(named: pose.rawValue) {
            return image
        }
        if let idleImage = image(named: DesktopPetPose.idle.rawValue) {
            return idleImage
        }
        return image(named: desktopPetImageName)
    }

    private static func image(named name: String) -> NSImage? {
        Bundle.module.url(forResource: name, withExtension: "png")
            .flatMap(NSImage.init(contentsOf:))
    }
}

@main
struct MomoPetApp: App {
    @StateObject private var store: PetStore

    init() {
        let repository = PetRepository(url: Self.saveURL)
        let profile = (try? repository.load()) ?? PetProfile()
        let store = PetStore(profile: profile, repository: repository)
        let now = Date()
        if let lastOpened = UserDefaults.standard.object(forKey: Self.lastOpenedKey) as? Date {
            store.reconcileOfflineTime(since: lastOpened, now: now)
        }
        UserDefaults.standard.set(now, forKey: Self.lastOpenedKey)
        _store = StateObject(wrappedValue: store)
    }

    var body: some Scene {
        WindowGroup(AppMetadata.name) {
            AcademyView()
                .environmentObject(store)
                .background(FloatingPetWindowConfigurator())
        }
        .windowStyle(.hiddenTitleBar)
    }

    private static var saveURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("MomoPet", isDirectory: true).appendingPathComponent("pet.json")
    }

    private static let lastOpenedKey = "momoPetLastOpened"
}

private struct AcademyView: View {
    @EnvironmentObject private var store: PetStore
    @State private var showingRoom = false
    @State private var panelMode: PetPanelMode = .academy
    @State private var desktopPetIsVisible = false
    @State private var courseFeedback: String?

    var body: some View {
        Group {
        if desktopPetIsVisible {
            Color.clear
        } else {
        HStack(alignment: .top, spacing: 20) {
            if panelMode == .compact {
                compactPet
            } else {
                rabbitCard
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("学堂成长 · \(store.profile.schoolStage == .kindergarten ? "幼儿园" : "小学")")
                            .font(.title2.bold())
                        Text("幼儿园  →  小学  →  中学  →  学院  →  毕业旅行")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        statGrid
                        eventCard
                        Text("今日课程").font(.headline)
                        courseRow
                        if let courseFeedback {
                            Label(courseFeedback, systemImage: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("点击任意课程开始上课，完成后获得学习印记。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        WeeklyGrowthCard()
                    }
                    .padding(.trailing, 8)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        }
        }
        .padding(24)
        .frame(minWidth: 760, minHeight: 430)
        .background(Color(red: 1.0, green: 0.97, blue: 0.89))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
        .sheet(isPresented: $showingRoom) {
            RoomView()
                .environmentObject(store)
        }
    }

    private var academyActions: some View {
        HStack(spacing: 8) {
            Menu("照料") {
                Button("喂食") { store.dispatch(.fed) }
                Button("摸摸") { store.dispatch(.petted) }
                Button("清洁") { store.dispatch(.cleaned) }
                Button("休息") { store.dispatch(.rested) }
            }
            Button("小屋") { showingRoom = true }
            if !store.profile.rewards.isEmpty {
                Menu("衣橱") {
                    ForEach(store.profile.rewards.sorted(), id: \.self) { accessory in
                        Button(accessory) { store.dispatch(.accessoryEquipped(accessory)) }
                    }
                }
            }
        }
        .controlSize(.small)
    }

    private var desktopPetButton: some View {
        Button("收起为桌宠") {
            let academyWindow = NSApp.keyWindow
            desktopPetIsVisible = true
            DesktopPetWindowController.shared.show(store: store) {
                desktopPetIsVisible = false
                academyWindow?.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            academyWindow?.orderOut(nil)
        }
        .buttonStyle(.borderedProminent)
    }

    private var rabbitCard: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                RabbitPortraitView(profile: store.profile, size: 235)
                    .frame(width: 210, height: 235)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                if let accessory = store.profile.equippedAccessory,
                   let presentation = RoomRewardPresentation.forReward(accessory) {
                    Image(systemName: presentation.symbol)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(9)
                        .background(.white.opacity(0.85), in: Circle())
                        .padding(10)
                }
            }
            Text("小白 · \(activityTitle)").font(.headline)
            Text(store.profile.equippedAccessory ?? "还没有佩戴配饰")
                .font(.caption).foregroundColor(.blue)
            Text("饱食 \(store.profile.hunger.value)  ·  心情 \(store.profile.mood.value)  ·  精力 \(store.profile.energy.value)")
                .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)
            desktopPetButton
            academyActions
        }
        .frame(width: 245)
    }

    private var compactPet: some View {
        VStack(spacing: 10) {
            rabbitCard
            Button("打开学堂") { panelMode = .academy }
                .buttonStyle(.borderedProminent)
        }
        .frame(width: 270)
    }

    private var activityTitle: String {
        switch PetActivity.current(for: store.profile) {
        case .studying: return "认真学习中"
        case .hopping: return "开心蹦跳中"
        case .napping: return "午睡中"
        case .hungry: return "肚子咕咕叫"
        case .lonely: return "想要摸摸"
        }
    }

    private var statGrid: some View {
        VStack(spacing: 7) {
            StatRow(name: "智力", value: store.profile.intelligence.value, tint: .blue)
            StatRow(name: "武力", value: store.profile.strength.value, tint: .orange)
            StatRow(name: "魅力", value: store.profile.charm.value, tint: .pink)
            StatRow(name: "创造力", value: store.profile.creativity.value, tint: .purple)
            StatRow(name: "勇气", value: store.profile.courage.value, tint: .green)
        }
        .environment(\.controlActiveState, .active)
    }

    @ViewBuilder
    private var courseRow: some View {
        HStack {
            if store.profile.schoolStage == .primarySchool {
                CourseButton(title: "阅读课", benefit: "智力 +7 · 创造力 +3", icon: "book.closed", color: .blue) { completePrimaryCourse(.reading, feedback: "阅读课完成：获得 1 枚学习印记") }
                CourseButton(title: "科学观察", benefit: "智力 +5 · 勇气 +4", icon: "magnifyingglass", color: .purple) { completePrimaryCourse(.science, feedback: "科学观察完成：获得 1 枚学习印记") }
                CourseButton(title: "运动社团", benefit: "武力 +7 · 魅力 +3", icon: "figure.run", color: .orange) { completePrimaryCourse(.sportsClub, feedback: "运动社团完成：获得 1 枚学习印记") }
            } else {
                CourseButton(title: "识字小课", benefit: "智力 +8 · 创造力 +4", icon: "character.book.closed", color: .blue) { completeCourse(.literacy, feedback: "识字小课完成：获得 1 枚学习印记") }
                CourseButton(title: "跳跳训练", benefit: "武力 +8 · 勇气 +4", icon: "figure.jump", color: .orange) { completeCourse(.jumping, feedback: "跳跳训练完成：获得 1 枚学习印记") }
                CourseButton(title: "小小舞台", benefit: "魅力 +8 · 勇气 +3", icon: "theatermasks", color: .pink) { completeCourse(.stage, feedback: "小小舞台完成：获得 1 枚学习印记") }
            }
        }
    }

    private func completeCourse(_ course: Course, feedback: String) {
        store.dispatch(.datedCourseCompleted(course, period: .current()))
        courseFeedback = feedback
    }

    private func completePrimaryCourse(_ course: PrimaryCourse, feedback: String) {
        store.dispatch(.datedPrimaryCourseCompleted(course, period: .current()))
        courseFeedback = feedback
    }

    @ViewBuilder
    private var eventCard: some View {
        if store.profile.schoolStage == .primarySchool {
            primaryEventCard
        } else {
            kindergartenEventCard
        }
    }

    @ViewBuilder
    private var kindergartenEventCard: some View {
        let available = KindergartenEvent.allCases.first {
            store.profile.kindergartenXP >= $0.requiredXP && !store.profile.completedEvents.contains($0)
        }
        if store.profile.isKindergartenGraduate && store.profile.schoolStage == .kindergarten {
            HStack {
                Text("🎓").font(.title)
                VStack(alignment: .leading) {
                    Text("幼儿园毕业啦！").font(.headline)
                    Text("已解锁：小学入学礼与毕业旅行纪念。")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button("前往小学") { store.dispatch(.graduationClaimed) }
                    .buttonStyle(.borderedProminent)
            }
            .padding(10)
            .background(Color.yellow.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if let event = available {
            HStack {
                VStack(alignment: .leading) {
                    Text("成长事件：\(event.title)").font(.headline)
                    Text("奖励：\(event.rewardName)").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button("领取") { store.dispatch(.kindergartenEventClaimed(event)) }
                    .buttonStyle(.borderedProminent)
            }
            .padding(10)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Text("成长经验：\(store.profile.kindergartenXP) · 继续上课解锁幼儿园事件")
                .font(.caption).foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var primaryEventCard: some View {
        let available = PrimaryEvent.allCases.first {
            store.profile.primaryXP >= $0.requiredXP && !store.profile.completedPrimaryEvents.contains($0)
        }
        if store.profile.isPrimarySchoolComplete {
            HStack {
                Text("🎒").font(.title)
                VStack(alignment: .leading) {
                    Text("小学结业啦！").font(.headline)
                    Text("中学内容筹备中，先带着小白享受校园时光吧。")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(10)
            .background(Color.green.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if let event = available {
            HStack {
                VStack(alignment: .leading) {
                    Text("班级事件：\(event.title)").font(.headline)
                    Text("奖励：\(event.rewardName)").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button("领取") { store.dispatch(.primaryEventClaimed(event)) }
                    .buttonStyle(.borderedProminent)
            }
            .padding(10)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Text("小学经验：\(store.profile.primaryXP) · 完成课程解锁班级事件")
                .font(.caption).foregroundColor(.secondary)
        }
    }
}

private struct RoomView: View {
    @EnvironmentObject private var store: PetStore
    @Environment(\.dismiss) private var dismiss
    @State private var roomFeedback: String?

    private var furnitureRewards: [String] {
        store.profile.rewards.filter {
            guard let presentation = RoomRewardPresentation.forReward($0) else { return false }
            return presentation.kind == .furniture || presentation.kind == .keepsake
        }.sorted()
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack { Text("小白的小屋").font(.title2.bold()); Spacer(); Button("完成") { dismiss() } }
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.87, green: 0.79, blue: 0.65))
                VStack {
                    HStack {
                        Label("休息区", systemImage: "bed.double.fill").font(.caption.bold()).foregroundColor(.white.opacity(0.85))
                        Spacer()
                        Label("学习角", systemImage: "books.vertical.fill").font(.caption.bold()).foregroundColor(.white.opacity(0.85))
                    }
                    Spacer()
                    HStack { Text("🛏️").font(.system(size: 62)); Spacer(); Text("🪴").font(.system(size: 48)) }
                }
                .padding(28)
                if store.profile.placedFurniture.contains("云朵绘本") {
                    Text("📖").font(.system(size: 56)).offset(x: -85, y: -25)
                }
                if store.profile.placedFurniture.contains("星星奖牌") {
                    Text("🏅").font(.system(size: 46)).offset(x: 78, y: -95)
                }
                if store.profile.placedFurniture.contains("小舞台摆件") {
                    Text("🎭").font(.system(size: 50)).offset(x: 0, y: -48)
                }
                if store.profile.placedFurniture.contains("彩虹积木") {
                    Text("🧊").font(.system(size: 42)).offset(x: -118, y: 78)
                }
                if store.profile.placedFurniture.contains("小阅读灯") {
                    Image(systemName: "lamp.desk.fill").font(.system(size: 38)).foregroundColor(.yellow).offset(x: 105, y: -40)
                }
                if store.profile.placedFurniture.contains("认真小贴纸") || store.profile.placedFurniture.contains("班级小贴纸") {
                    Image(systemName: "star.fill").font(.system(size: 30)).foregroundColor(.orange).offset(x: 112, y: -105)
                }
            }
            .frame(height: 260)
            if let roomFeedback {
                Label(roomFeedback, systemImage: "sparkles")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            if furnitureRewards.isEmpty {
                Text("完成成长事件后，家具会出现在这里。")
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    ForEach(furnitureRewards, id: \.self) { furniture in
                        Button(store.profile.placedFurniture.contains(furniture) ? "收起 \(furniture)" : "摆放 \(furniture)") {
                            if store.profile.placedFurniture.contains(furniture) {
                                store.removeFurniture(furniture)
                                roomFeedback = "已收起 \(furniture)"
                            } else {
                                store.dispatch(.furniturePlaced(furniture))
                                roomFeedback = "新布置完成：\(furniture)"
                            }
                        }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 520, height: 430)
        .background(Color(red: 1.0, green: 0.97, blue: 0.89))
    }
}

private extension KindergartenEvent {
    var title: String {
        switch self {
        case .introduction: return "第一次自我介绍"
        case .quiz: return "准备小测验"
        case .sportsDay: return "幼儿园运动会"
        case .showcase: return "展示日"
        }
    }

    var rewardName: String {
        switch self {
        case .introduction: return "蓝色领结"
        case .quiz: return "云朵绘本"
        case .sportsDay: return "星星奖牌"
        case .showcase: return "小舞台摆件"
        }
    }
}

private extension PrimaryEvent {
    var title: String {
        switch self {
        case .introduction: return "新生自我介绍"
        case .carrotGarden: return "胡萝卜花圃"
        case .sportsDay: return "班级运动日"
        case .showcase: return "作品展示"
        }
    }

    var rewardName: String {
        switch self {
        case .introduction: return "小红领巾"
        case .carrotGarden: return "花圃小徽章"
        case .sportsDay: return "运动水壶"
        case .showcase: return "云朵书包"
        }
    }
}

private struct StarCatchView: View {
    let won: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var caught = false

    var body: some View {
        VStack(spacing: 22) {
            Text("接星星").font(.title.bold())
            Text(caught ? "小白接住星星啦！心情 +8，成长经验 +5" : "在星星落地前点一下它！")
                .foregroundColor(.secondary)
            Button {
                guard !caught else { return }
                caught = true
                won()
            } label: {
                Image(systemName: caught ? "star.fill" : "star.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
            }
            Button(caught ? "完成" : "稍后再玩") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(36)
        .frame(width: 380, height: 300)
        .background(Color(red: 0.95, green: 0.98, blue: 1.0))
    }
}

private struct FloatingPetWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.level = .floating
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private struct StatRow: View {
    let name: String
    let value: Int
    let tint: Color
    var body: some View {
        HStack { Text(name).frame(width: 48, alignment: .leading); ProgressView(value: Double(value), total: 100).tint(tint); Text("\(value)").monospacedDigit().frame(width: 30, alignment: .trailing) }
    }
}

private struct CourseButton: View {
    let title: String
    let benefit: String
    let icon: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.subheadline.bold())
                Text(benefit).font(.caption2)
                Text("点击上课").font(.caption2.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 88)
            .foregroundColor(.white)
            .background(color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(width: 155)
    }
}
