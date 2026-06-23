import XCTest
@testable import MomoPetApp

final class RoomRewardPresentationTests: XCTestCase {
    func testFurnitureRewardsUseExpectedRoomSlots() {
        XCTAssertEqual(RoomRewardPresentation.forReward("云朵绘本")?.slot, .bookshelf)
        XCTAssertEqual(RoomRewardPresentation.forReward("星星奖牌")?.slot, .trophyWall)
        XCTAssertEqual(RoomRewardPresentation.forReward("小阅读灯")?.slot, .desk)
    }

    func testWearableRewardsAreNotFurniture() {
        XCTAssertEqual(RoomRewardPresentation.forReward("蓝色领结")?.kind, .accessory)
        XCTAssertEqual(RoomRewardPresentation.forReward("小明星徽章")?.kind, .accessory)
    }
}
