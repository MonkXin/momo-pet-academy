import Foundation

struct StudyPeriod: Codable, Equatable {
    let dayID: String
    let weekID: String

    static func current(calendar: Calendar = .current, date: Date = Date()) -> Self {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let dayID = formatter.string(from: date)

        formatter.dateFormat = "YYYY-'W'ww"
        return Self(dayID: dayID, weekID: formatter.string(from: date))
    }
}

struct WeeklyGrowthContent: Equatable {
    let title: String
    let journal: String
    let rewardName: String
}

enum WeeklyGrowthMilestone: String, Codable, CaseIterable, Hashable {
    case attentive
    case explorer
    case star

    var requiredStamps: Int {
        switch self {
        case .attentive: return 3
        case .explorer: return 6
        case .star: return 10
        }
    }

    func content(for stage: SchoolStage) -> WeeklyGrowthContent {
        switch (stage, self) {
        case (.kindergarten, .attentive):
            return .init(title: "认真听讲", journal: "老师送给奶茶一张认真小贴纸。", rewardName: "认真小贴纸")
        case (.kindergarten, .explorer):
            return .init(title: "课间探索", journal: "奶茶在课间发现了彩虹积木角。", rewardName: "彩虹积木")
        case (.kindergarten, .star):
            return .init(title: "本周小明星", journal: "奶茶拿到了幼儿园小明星徽章。", rewardName: "小明星徽章")
        case (.primarySchool, .attentive):
            return .init(title: "认真听讲", journal: "班主任把班级小贴纸贴进了奶茶的成长册。", rewardName: "班级小贴纸")
        case (.primarySchool, .explorer):
            return .init(title: "课间探索", journal: "奶茶在图书角找到了一盏小阅读灯。", rewardName: "小阅读灯")
        case (.primarySchool, .star):
            return .init(title: "本周小明星", journal: "奶茶收到了一枚校园小明星别针。", rewardName: "校园小明星别针")
        }
    }
}

enum WeeklyStudyRule {
    static func multiplier(forCompletedCourses count: Int) -> Double {
        switch count {
        case ..<1: return 1
        case 1: return 0.7
        default: return 0.4
        }
    }

    static func scaled(_ value: Int, completedCourses: Int) -> Int {
        guard value != 0 else { return 0 }
        return max(1, Int((Double(value) * multiplier(forCompletedCourses: completedCourses)).rounded(.down)))
    }
}
