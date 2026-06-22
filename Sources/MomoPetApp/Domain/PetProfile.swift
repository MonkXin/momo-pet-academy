import Foundation

struct Stat: Codable, Equatable {
    let value: Int

    init(value: Int) {
        self.value = min(100, max(0, value))
    }

    func changed(by amount: Int) -> Stat {
        Stat(value: value + amount)
    }
}

enum Course: String, Codable, CaseIterable {
    case literacy
    case jumping
    case stage
}

enum PrimaryCourse: String, Codable, CaseIterable {
    case reading
    case science
    case sportsClub
}

enum MiniGame: String, Codable {
    case starCatch
}

enum SchoolStage: String, Codable {
    case kindergarten
    case primarySchool
}

enum KindergartenEvent: String, Codable, CaseIterable, Hashable {
    case introduction
    case quiz
    case sportsDay
    case showcase

    var requiredXP: Int {
        switch self {
        case .introduction: return 10
        case .quiz: return 25
        case .sportsDay: return 45
        case .showcase: return 70
        }
    }
}

enum PrimaryEvent: String, Codable, CaseIterable, Hashable {
    case introduction
    case carrotGarden
    case sportsDay
    case showcase

    var requiredXP: Int {
        switch self {
        case .introduction: return 30
        case .carrotGarden: return 60
        case .sportsDay: return 90
        case .showcase: return 120
        }
    }
}

enum PetEvent {
    case fed
    case petted
    case rested
    case cleaned
    case courseCompleted(Course)
    case primaryCourseCompleted(PrimaryCourse)
    case datedCourseCompleted(Course, period: StudyPeriod)
    case datedPrimaryCourseCompleted(PrimaryCourse, period: StudyPeriod)
    case weeklyGrowthClaimed(WeeklyGrowthMilestone, period: StudyPeriod)
    case weeklyGrowthPromptAcknowledged(WeeklyGrowthMilestone, period: StudyPeriod)
    case miniGameCompleted(MiniGame, won: Bool)
    case kindergartenEventClaimed(KindergartenEvent)
    case primaryEventClaimed(PrimaryEvent)
    case accessoryEquipped(String)
    case furniturePlaced(String)
    case dayPassed(days: Int)
    case graduationClaimed
    case recoveredOffline(days: Int)
}

struct PetProfile: Codable, Equatable {
    var hunger: Stat
    var mood: Stat
    var cleanliness: Stat
    var energy: Stat
    var intelligence: Stat
    var strength: Stat
    var charm: Stat
    var creativity: Stat
    var courage: Stat
    var kindergartenXP: Int
    var completedEvents: Set<KindergartenEvent>
    var primaryXP: Int
    var completedPrimaryEvents: Set<PrimaryEvent>
    var rewards: Set<String>
    var equippedAccessory: String?
    var placedFurniture: Set<String>
    var schoolStage: SchoolStage
    var lastStudyDay: String?
    var studyCountOnLastStudyDay: Int
    var weeklyStudyStampCount: Int
    var weeklyGrowthWeekID: String?
    var claimedWeeklyGrowthMilestones: Set<WeeklyGrowthMilestone>
    var announcedWeeklyGrowthMilestones: Set<WeeklyGrowthMilestone>
    var weeklyGrowthJournal: [String]

    init(
        hunger: Stat = Stat(value: 80), mood: Stat = Stat(value: 80), cleanliness: Stat = Stat(value: 80), energy: Stat = Stat(value: 80),
        intelligence: Stat = Stat(value: 0), strength: Stat = Stat(value: 0), charm: Stat = Stat(value: 0), creativity: Stat = Stat(value: 0), courage: Stat = Stat(value: 0),
        kindergartenXP: Int = 0, completedEvents: Set<KindergartenEvent> = [], primaryXP: Int = 0, completedPrimaryEvents: Set<PrimaryEvent> = [], rewards: Set<String> = [], equippedAccessory: String? = nil,
        placedFurniture: Set<String> = [], schoolStage: SchoolStage = .kindergarten,
        lastStudyDay: String? = nil, studyCountOnLastStudyDay: Int = 0, weeklyStudyStampCount: Int = 0, weeklyGrowthWeekID: String? = nil,
        claimedWeeklyGrowthMilestones: Set<WeeklyGrowthMilestone> = [], announcedWeeklyGrowthMilestones: Set<WeeklyGrowthMilestone> = [], weeklyGrowthJournal: [String] = []
    ) {
        self.hunger = hunger; self.mood = mood; self.cleanliness = cleanliness; self.energy = energy
        self.intelligence = intelligence; self.strength = strength; self.charm = charm; self.creativity = creativity; self.courage = courage
        self.kindergartenXP = kindergartenXP; self.completedEvents = completedEvents; self.primaryXP = primaryXP; self.completedPrimaryEvents = completedPrimaryEvents; self.rewards = rewards
        self.equippedAccessory = equippedAccessory; self.placedFurniture = placedFurniture; self.schoolStage = schoolStage
        self.lastStudyDay = lastStudyDay; self.studyCountOnLastStudyDay = studyCountOnLastStudyDay; self.weeklyStudyStampCount = weeklyStudyStampCount; self.weeklyGrowthWeekID = weeklyGrowthWeekID
        self.claimedWeeklyGrowthMilestones = claimedWeeklyGrowthMilestones; self.announcedWeeklyGrowthMilestones = announcedWeeklyGrowthMilestones; self.weeklyGrowthJournal = weeklyGrowthJournal
    }

    private enum CodingKeys: String, CodingKey {
        case hunger, mood, cleanliness, energy, intelligence, strength, charm, creativity, courage
        case kindergartenXP, completedEvents, primaryXP, completedPrimaryEvents, rewards, equippedAccessory, placedFurniture, schoolStage
        case lastStudyDay, studyCountOnLastStudyDay, weeklyStudyStampCount, weeklyGrowthWeekID, claimedWeeklyGrowthMilestones, announcedWeeklyGrowthMilestones, weeklyGrowthJournal
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            hunger: try c.decodeIfPresent(Stat.self, forKey: .hunger) ?? Stat(value: 80),
            mood: try c.decodeIfPresent(Stat.self, forKey: .mood) ?? Stat(value: 80),
            cleanliness: try c.decodeIfPresent(Stat.self, forKey: .cleanliness) ?? Stat(value: 80),
            energy: try c.decodeIfPresent(Stat.self, forKey: .energy) ?? Stat(value: 80),
            intelligence: try c.decodeIfPresent(Stat.self, forKey: .intelligence) ?? Stat(value: 0),
            strength: try c.decodeIfPresent(Stat.self, forKey: .strength) ?? Stat(value: 0),
            charm: try c.decodeIfPresent(Stat.self, forKey: .charm) ?? Stat(value: 0),
            creativity: try c.decodeIfPresent(Stat.self, forKey: .creativity) ?? Stat(value: 0),
            courage: try c.decodeIfPresent(Stat.self, forKey: .courage) ?? Stat(value: 0),
            kindergartenXP: try c.decodeIfPresent(Int.self, forKey: .kindergartenXP) ?? 0,
            completedEvents: try c.decodeIfPresent(Set<KindergartenEvent>.self, forKey: .completedEvents) ?? [],
            primaryXP: try c.decodeIfPresent(Int.self, forKey: .primaryXP) ?? 0,
            completedPrimaryEvents: try c.decodeIfPresent(Set<PrimaryEvent>.self, forKey: .completedPrimaryEvents) ?? [],
            rewards: try c.decodeIfPresent(Set<String>.self, forKey: .rewards) ?? [],
            equippedAccessory: try c.decodeIfPresent(String.self, forKey: .equippedAccessory),
            placedFurniture: try c.decodeIfPresent(Set<String>.self, forKey: .placedFurniture) ?? [],
            schoolStage: try c.decodeIfPresent(SchoolStage.self, forKey: .schoolStage) ?? .kindergarten,
            lastStudyDay: try c.decodeIfPresent(String.self, forKey: .lastStudyDay),
            studyCountOnLastStudyDay: try c.decodeIfPresent(Int.self, forKey: .studyCountOnLastStudyDay) ?? 0,
            weeklyStudyStampCount: try c.decodeIfPresent(Int.self, forKey: .weeklyStudyStampCount) ?? 0,
            weeklyGrowthWeekID: try c.decodeIfPresent(String.self, forKey: .weeklyGrowthWeekID),
            claimedWeeklyGrowthMilestones: try c.decodeIfPresent(Set<WeeklyGrowthMilestone>.self, forKey: .claimedWeeklyGrowthMilestones) ?? [],
            announcedWeeklyGrowthMilestones: try c.decodeIfPresent(Set<WeeklyGrowthMilestone>.self, forKey: .announcedWeeklyGrowthMilestones) ?? [],
            weeklyGrowthJournal: try c.decodeIfPresent([String].self, forKey: .weeklyGrowthJournal) ?? []
        )
    }

    var isKindergartenGraduate: Bool {
        kindergartenXP >= 70 && completedEvents == Set(KindergartenEvent.allCases)
    }

    var isPrimarySchoolComplete: Bool {
        schoolStage == .primarySchool && primaryXP >= 120 && completedPrimaryEvents == Set(PrimaryEvent.allCases)
    }

    var nextWeeklyGrowthMilestone: WeeklyGrowthMilestone? {
        WeeklyGrowthMilestone.allCases.first {
            weeklyStudyStampCount >= $0.requiredStamps && !claimedWeeklyGrowthMilestones.contains($0)
        }
    }

    mutating func normalizeWeeklyStudyProgress(for period: StudyPeriod) {
        if weeklyGrowthWeekID != period.weekID {
            weeklyGrowthWeekID = period.weekID
            weeklyStudyStampCount = 0
            claimedWeeklyGrowthMilestones = []
            announcedWeeklyGrowthMilestones = []
            weeklyGrowthJournal = []
        }
        if lastStudyDay != period.dayID {
            lastStudyDay = period.dayID
            studyCountOnLastStudyDay = 0
        }
    }

}

enum PetReducer {
    static func reduce(_ event: PetEvent, profile: PetProfile) -> PetProfile {
        var next = profile
        switch event {
        case .fed:
            next.hunger = next.hunger.changed(by: 18)
        case .petted:
            next.mood = next.mood.changed(by: 12)
        case .rested:
            next.energy = next.energy.changed(by: 20)
        case .cleaned:
            next.cleanliness = next.cleanliness.changed(by: 25)
        case .miniGameCompleted(_, let won):
            guard won else { return next }
            next.mood = next.mood.changed(by: 8)
            next.kindergartenXP += 5
        case .kindergartenEventClaimed(let event):
            guard next.kindergartenXP >= event.requiredXP, !next.completedEvents.contains(event) else { return next }
            next.completedEvents.insert(event)
            switch event {
            case .introduction:
                next.charm = next.charm.changed(by: 3)
                next.rewards.insert("蓝色领结")
            case .quiz:
                next.intelligence = next.intelligence.changed(by: 3)
                next.rewards.insert("云朵绘本")
            case .sportsDay:
                next.strength = next.strength.changed(by: 3)
                next.rewards.insert("星星奖牌")
            case .showcase:
                next.creativity = next.creativity.changed(by: 3)
                next.rewards.insert("小舞台摆件")
            }
        case .primaryEventClaimed(let event):
            guard next.schoolStage == .primarySchool, next.primaryXP >= event.requiredXP, !next.completedPrimaryEvents.contains(event) else { return next }
            next.completedPrimaryEvents.insert(event)
            switch event {
            case .introduction:
                next.charm = next.charm.changed(by: 3)
                next.rewards.insert("小红领巾")
            case .carrotGarden:
                next.creativity = next.creativity.changed(by: 3)
                next.rewards.insert("花圃小徽章")
            case .sportsDay:
                next.strength = next.strength.changed(by: 3)
                next.rewards.insert("运动水壶")
            case .showcase:
                next.intelligence = next.intelligence.changed(by: 3)
                next.rewards.insert("云朵书包")
            }
        case .accessoryEquipped(let accessory):
            guard next.rewards.contains(accessory) else { return next }
            next.equippedAccessory = accessory
        case .furniturePlaced(let furniture):
            guard next.rewards.contains(furniture) else { return next }
            next.placedFurniture.insert(furniture)
        case .dayPassed(let days):
            let cappedDays = min(7, max(0, days))
            next.hunger = next.hunger.changed(by: -6 * cappedDays)
            next.cleanliness = next.cleanliness.changed(by: -4 * cappedDays)
            next.energy = next.energy.changed(by: -3 * cappedDays)
        case .graduationClaimed:
            guard next.isKindergartenGraduate else { return next }
            next.schoolStage = .primarySchool
        case .recoveredOffline(let days):
            let cappedDays = min(3, max(0, days))
            next.energy = next.energy.changed(by: cappedDays * 8)
            next.mood = next.mood.changed(by: cappedDays * 4)
        case .courseCompleted(.literacy):
            next.intelligence = next.intelligence.changed(by: 8)
            next.creativity = next.creativity.changed(by: 4)
            next.energy = next.energy.changed(by: -8)
            next.kindergartenXP += 10
        case .courseCompleted(.jumping):
            next.strength = next.strength.changed(by: 8)
            next.courage = next.courage.changed(by: 4)
            next.energy = next.energy.changed(by: -10)
            next.kindergartenXP += 10
        case .courseCompleted(.stage):
            next.charm = next.charm.changed(by: 8)
            next.courage = next.courage.changed(by: 3)
            next.energy = next.energy.changed(by: -7)
            next.kindergartenXP += 10
        case .primaryCourseCompleted(let course):
            guard next.schoolStage == .primarySchool else { return next }
            switch course {
            case .reading:
                next.intelligence = next.intelligence.changed(by: 7)
                next.creativity = next.creativity.changed(by: 3)
                next.energy = next.energy.changed(by: -7)
            case .science:
                next.intelligence = next.intelligence.changed(by: 5)
                next.courage = next.courage.changed(by: 4)
                next.energy = next.energy.changed(by: -8)
            case .sportsClub:
                next.strength = next.strength.changed(by: 7)
                next.charm = next.charm.changed(by: 3)
                next.energy = next.energy.changed(by: -9)
            }
            next.primaryXP += 10
        case .datedCourseCompleted(let course, let period):
            next.normalizeWeeklyStudyProgress(for: period)
            let count = next.studyCountOnLastStudyDay
            switch course {
            case .literacy:
                next.intelligence = next.intelligence.changed(by: WeeklyStudyRule.scaled(8, completedCourses: count))
                next.creativity = next.creativity.changed(by: WeeklyStudyRule.scaled(4, completedCourses: count))
                next.energy = next.energy.changed(by: -WeeklyStudyRule.scaled(8, completedCourses: count))
                next.kindergartenXP += WeeklyStudyRule.scaled(10, completedCourses: count)
            case .jumping:
                next.strength = next.strength.changed(by: WeeklyStudyRule.scaled(8, completedCourses: count))
                next.courage = next.courage.changed(by: WeeklyStudyRule.scaled(4, completedCourses: count))
                next.energy = next.energy.changed(by: -WeeklyStudyRule.scaled(10, completedCourses: count))
                next.kindergartenXP += WeeklyStudyRule.scaled(10, completedCourses: count)
            case .stage:
                next.charm = next.charm.changed(by: WeeklyStudyRule.scaled(8, completedCourses: count))
                next.courage = next.courage.changed(by: WeeklyStudyRule.scaled(3, completedCourses: count))
                next.energy = next.energy.changed(by: -WeeklyStudyRule.scaled(7, completedCourses: count))
                next.kindergartenXP += WeeklyStudyRule.scaled(10, completedCourses: count)
            }
            next.studyCountOnLastStudyDay += 1
            next.weeklyStudyStampCount = min(10, next.weeklyStudyStampCount + 1)
        case .datedPrimaryCourseCompleted(let course, let period):
            guard next.schoolStage == .primarySchool else { return next }
            next.normalizeWeeklyStudyProgress(for: period)
            let count = next.studyCountOnLastStudyDay
            switch course {
            case .reading:
                next.intelligence = next.intelligence.changed(by: WeeklyStudyRule.scaled(7, completedCourses: count))
                next.creativity = next.creativity.changed(by: WeeklyStudyRule.scaled(3, completedCourses: count))
                next.energy = next.energy.changed(by: -WeeklyStudyRule.scaled(7, completedCourses: count))
            case .science:
                next.intelligence = next.intelligence.changed(by: WeeklyStudyRule.scaled(5, completedCourses: count))
                next.courage = next.courage.changed(by: WeeklyStudyRule.scaled(4, completedCourses: count))
                next.energy = next.energy.changed(by: -WeeklyStudyRule.scaled(8, completedCourses: count))
            case .sportsClub:
                next.strength = next.strength.changed(by: WeeklyStudyRule.scaled(7, completedCourses: count))
                next.charm = next.charm.changed(by: WeeklyStudyRule.scaled(3, completedCourses: count))
                next.energy = next.energy.changed(by: -WeeklyStudyRule.scaled(9, completedCourses: count))
            }
            next.primaryXP += WeeklyStudyRule.scaled(10, completedCourses: count)
            next.studyCountOnLastStudyDay += 1
            next.weeklyStudyStampCount = min(10, next.weeklyStudyStampCount + 1)
        case .weeklyGrowthClaimed(let milestone, let period):
            next.normalizeWeeklyStudyProgress(for: period)
            guard next.weeklyStudyStampCount >= milestone.requiredStamps, !next.claimedWeeklyGrowthMilestones.contains(milestone) else { return next }
            let content = milestone.content(for: next.schoolStage)
            next.claimedWeeklyGrowthMilestones.insert(milestone)
            next.weeklyGrowthJournal.append(content.journal)
            next.rewards.insert(content.rewardName)
        case .weeklyGrowthPromptAcknowledged(let milestone, let period):
            next.normalizeWeeklyStudyProgress(for: period)
            next.announcedWeeklyGrowthMilestones.insert(milestone)
        }
        return next
    }
}

enum PetActivity: Equatable {
    case studying
    case hopping
    case napping
    case hungry
    case lonely

    static func current(for profile: PetProfile) -> PetActivity {
        if profile.energy.value < 20 { return .napping }
        if profile.hunger.value < 30 { return .hungry }
        if profile.mood.value < 30 { return .lonely }
        return .studying
    }
}

enum PetPanelMode: Equatable {
    case compact
    case academy

    var toggled: PetPanelMode {
        self == .compact ? .academy : .compact
    }
}
