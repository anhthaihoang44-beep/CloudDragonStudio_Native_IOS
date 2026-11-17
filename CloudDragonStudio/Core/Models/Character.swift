import Foundation

enum DragonZone: String, CaseIterable, Codable, Identifiable, Sendable {
    case scales
    case horns
    case wings
    case tail

    var id: String { rawValue }
}

struct CloudDragonCharacter: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var bodyColor: CodableColor
    var bellyColor: CodableColor
    var hornColor: CodableColor
    var wingColor: CodableColor
    var tailColor: CodableColor
    var sparkleLevel: Double
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "Puff",
        bodyColor: CodableColor = PastelPalette.mint,
        bellyColor: CodableColor = PastelPalette.butterYellow,
        hornColor: CodableColor = PastelPalette.butterGold,
        wingColor: CodableColor = PastelPalette.lavender,
        tailColor: CodableColor = PastelPalette.mintDeep,
        sparkleLevel: Double = 1.0,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.bodyColor = bodyColor
        self.bellyColor = bellyColor
        self.hornColor = hornColor
        self.wingColor = wingColor
        self.tailColor = tailColor
        self.sparkleLevel = sparkleLevel
        self.updatedAt = updatedAt
    }

    static var defaultDragon: CloudDragonCharacter {
        CloudDragonCharacter()
    }
}
