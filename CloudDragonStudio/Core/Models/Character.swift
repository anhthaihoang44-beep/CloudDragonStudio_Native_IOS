import Foundation

enum DragonZone: String, CaseIterable, Codable, Identifiable, Sendable {
    case belly
    case wings
    case horns
    case body
    case tail

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .belly: return "scale.zone.belly"
        case .wings: return "scale.zone.wings"
        case .horns: return "scale.zone.horns"
        case .body: return "scale.zone.body"
        case .tail: return "scale.zone.tail"
        }
    }
}

enum DragonExpression: String, Codable, CaseIterable, Sendable {
    case happy
    case delighted
    case sleepy
    case wink
    case eating
}

enum DragonPose: String, Codable, CaseIterable, Sendable {
    case sitting
    case waving
    case flying
}

struct CloudDragonCharacter: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var name: String
    var bodyColor: CodableColor
    var bellyColor: CodableColor
    var wingColor: CodableColor
    var hornColor: CodableColor
    var tailPuffColor: CodableColor

    // Per-part painting strokes & redo buffer (unlimited per-part Undo/Redo)
    var partStrokes: [DragonZone: [PaintStroke]]
    var redoStrokes: [DragonZone: [PaintStroke]]

    // Wardrobe equipped items keyed by ItemCategory rawValue -> CatalogItem.id
    var equippedItems: [String: String]
    // Custom color per equipped item ID
    var equippedColors: [String: CodableColor]

    var expression: DragonExpression
    var pose: DragonPose
    var isBathed: Bool
    var isDried: Bool
    var isBrushed: Bool
    var hungerLevel: Int
    var updatedAt: Date

    init(
        id: String = "slot_0",
        name: String = "Cloudy Baby",
        bodyColor: CodableColor = PastelPalette.mintGreen,
        bellyColor: CodableColor = PastelPalette.butterYellow,
        wingColor: CodableColor = PastelPalette.lavenderPurple,
        hornColor: CodableColor = PastelPalette.peachSoft,
        tailPuffColor: CodableColor = PastelPalette.cloudWhite,
        partStrokes: [DragonZone: [PaintStroke]]? = nil,
        redoStrokes: [DragonZone: [PaintStroke]]? = nil,
        equippedItems: [String: String] = [:],
        equippedColors: [String: CodableColor] = [:],
        expression: DragonExpression = .happy,
        pose: DragonPose = .sitting,
        isBathed: Bool = true,
        isDried: Bool = true,
        isBrushed: Bool = true,
        hungerLevel: Int = 3,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.bodyColor = bodyColor
        self.bellyColor = bellyColor
        self.wingColor = wingColor
        self.hornColor = hornColor
        self.tailPuffColor = tailPuffColor
        var initialStrokes: [DragonZone: [PaintStroke]] = [:]
        var initialRedo: [DragonZone: [PaintStroke]] = [:]
        for zone in DragonZone.allCases {
            initialStrokes[zone] = partStrokes?[zone] ?? []
            initialRedo[zone] = redoStrokes?[zone] ?? []
        }
        self.partStrokes = initialStrokes
        self.redoStrokes = initialRedo
        self.equippedItems = equippedItems
        self.equippedColors = equippedColors
        self.expression = expression
        self.pose = pose
        self.isBathed = isBathed
        self.isDried = isDried
        self.isBrushed = isBrushed
        self.hungerLevel = hungerLevel
        self.updatedAt = updatedAt
    }

    var allStrokes: [PaintStroke] {
        DragonZone.allCases.flatMap { partStrokes[$0] ?? [] }
    }

    func strokes(for zone: DragonZone) -> [PaintStroke] {
        partStrokes[zone] ?? []
    }

    func canUndo(zone: DragonZone) -> Bool {
        !(partStrokes[zone] ?? []).isEmpty
    }

    func canRedo(zone: DragonZone) -> Bool {
        !(redoStrokes[zone] ?? []).isEmpty
    }

    mutating func addStroke(_ stroke: PaintStroke) {
        var list = partStrokes[stroke.zone] ?? []
        list.append(stroke)
        partStrokes[stroke.zone] = list
        redoStrokes[stroke.zone] = []
        updatedAt = Date()
    }

    @discardableResult
    mutating func undo(zone: DragonZone) -> Bool {
        guard var list = partStrokes[zone], let last = list.popLast() else { return false }
        partStrokes[zone] = list
        var redo = redoStrokes[zone] ?? []
        redo.append(last)
        redoStrokes[zone] = redo
        updatedAt = Date()
        return true
    }

    @discardableResult
    mutating func redo(zone: DragonZone) -> Bool {
        guard var redo = redoStrokes[zone], let restored = redo.popLast() else { return false }
        redoStrokes[zone] = redo
        var list = partStrokes[zone] ?? []
        list.append(restored)
        partStrokes[zone] = list
        updatedAt = Date()
        return true
    }

    mutating func clear(zone: DragonZone) {
        partStrokes[zone] = []
        redoStrokes[zone] = []
        updatedAt = Date()
    }

    static var defaultDragon: CloudDragonCharacter {
        createPreset(slotIndex: 0)
    }

    static func createPreset(slotIndex: Int) -> CloudDragonCharacter {
        let names = [
            "Cloudy Baby",
            "Buttercup",
            "Minty Puff",
            "Lavender Star",
            "Peachy Pip",
            "Berry Swirl",
            "Moonbeam",
            "Bellflower",
            "Breezy Wing",
            "Dewdrop",
            "Sunny Sprout",
            "Cotton Candy"
        ]
        let bodyColors = [
            PastelPalette.mintGreen,
            PastelPalette.butterYellow,
            PastelPalette.lavenderPurple,
            PastelPalette.peachSoft,
            PastelPalette.skyBlue,
            PastelPalette.roseSoft
        ]
        let bellyColors = [
            PastelPalette.butterWarm,
            PastelPalette.mintLight,
            PastelPalette.roseLight,
            PastelPalette.skyLight,
            PastelPalette.peachLight,
            PastelPalette.butterWarm
        ]
        let safeIdx = max(0, slotIndex)
        return CloudDragonCharacter(
            id: "slot_\(safeIdx)",
            name: names[safeIdx % names.count],
            bodyColor: bodyColors[safeIdx % bodyColors.count],
            bellyColor: bellyColors[safeIdx % bellyColors.count],
            wingColor: bodyColors[(safeIdx + 2) % bodyColors.count],
            hornColor: PastelPalette.peachSoft,
            tailPuffColor: PastelPalette.butterWarm
        )
    }
}
