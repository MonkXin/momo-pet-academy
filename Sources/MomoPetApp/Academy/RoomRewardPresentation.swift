import Foundation

enum RoomRewardKind: Equatable {
    case furniture
    case accessory
    case keepsake
}

enum RoomSlot: Equatable {
    case bookshelf
    case trophyWall
    case displayStage
    case rug
    case desk
    case stickerWall
}

struct RoomRewardPresentation: Equatable {
    let kind: RoomRewardKind
    let slot: RoomSlot?
    let symbol: String

    static func forReward(_ reward: String) -> Self? {
        switch reward {
        case "云朵绘本": return .init(kind: .furniture, slot: .bookshelf, symbol: "book.closed.fill")
        case "星星奖牌": return .init(kind: .furniture, slot: .trophyWall, symbol: "medal.fill")
        case "小舞台摆件": return .init(kind: .furniture, slot: .displayStage, symbol: "theatermasks.fill")
        case "彩虹积木": return .init(kind: .furniture, slot: .rug, symbol: "cube.box.fill")
        case "小阅读灯": return .init(kind: .furniture, slot: .desk, symbol: "lamp.desk.fill")
        case "认真小贴纸", "班级小贴纸": return .init(kind: .keepsake, slot: .stickerWall, symbol: "star.fill")
        case "蓝色领结", "小红领巾", "小明星徽章", "校园小明星别针": return .init(kind: .accessory, slot: nil, symbol: "heart.fill")
        default: return nil
        }
    }
}
