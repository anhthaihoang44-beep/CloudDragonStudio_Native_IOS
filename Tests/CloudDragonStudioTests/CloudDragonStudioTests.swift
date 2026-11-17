import XCTest
@testable import CloudDragonStudio

final class CloudDragonStudioTests: XCTestCase {
    func testDefaultCharacterColorsAndZones() {
        let character = CloudDragonCharacter.defaultDragon
        XCTAssertEqual(character.name, "Puff")
        XCTAssertEqual(character.bodyColor, PastelPalette.mint)
        XCTAssertEqual(character.bellyColor, PastelPalette.butterYellow)
        XCTAssertEqual(character.wingColor, PastelPalette.lavender)
        XCTAssertEqual(DragonZone.allCases.count, 4)
    }

    func testCodableColorRoundTrip() throws {
        let original = CodableColor(hex: 0x9EEAD0, alpha: 0.85)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CodableColor.self, from: data)
        XCTAssertEqual(original, decoded)
    }
}
