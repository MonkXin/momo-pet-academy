import SwiftUI

struct WeeklyGrowthCard: View {
    @EnvironmentObject private var store: PetStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("本周成长").font(.headline)
                Spacer()
                Text("学习印记 \(min(store.profile.weeklyStudyStampCount, 10)) / 10")
                    .font(.caption).foregroundColor(.secondary)
            }

            ForEach(WeeklyGrowthMilestone.allCases, id: \.self) { milestone in
                milestoneRow(milestone)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func milestoneRow(_ milestone: WeeklyGrowthMilestone) -> some View {
        let content = milestone.content(for: store.profile.schoolStage)
        HStack(spacing: 8) {
            Image(systemName: store.profile.claimedWeeklyGrowthMilestones.contains(milestone) ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(store.profile.claimedWeeklyGrowthMilestones.contains(milestone) ? Color.green : Color.secondary)
            VStack(alignment: .leading, spacing: 1) {
                Text(content.title).font(.subheadline)
                if store.profile.claimedWeeklyGrowthMilestones.contains(milestone) {
                    Text(content.journal).font(.caption).foregroundColor(.secondary)
                } else if store.profile.weeklyStudyStampCount >= milestone.requiredStamps {
                    Text("已解锁：\(content.rewardName)").font(.caption).foregroundColor(.secondary)
                } else {
                    Text("还差 \(milestone.requiredStamps - store.profile.weeklyStudyStampCount) 枚印记").font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            if store.profile.weeklyStudyStampCount >= milestone.requiredStamps && !store.profile.claimedWeeklyGrowthMilestones.contains(milestone) {
                Button("领取成长小事") {
                    store.dispatch(.weeklyGrowthClaimed(milestone, period: .current()))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
    }
}
