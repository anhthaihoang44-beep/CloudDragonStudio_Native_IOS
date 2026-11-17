import CoreGraphics
import XCTest
@testable import CloudDragonStudio

final class CloudDragonStudioTests: XCTestCase {
    @MainActor
    func testDefaultCharacterAnd12SaveSlotsPersistence() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CloudDragonTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let service = PersistenceService(customDirectory: tempDir)
        var state = service.load()
        XCTAssertEqual(state.characters.count, 12)
        XCTAssertEqual(state.characters[0].name, "Cloudy Baby")

        state.activeSlotIndex = 3
        state.characters[3].equippedItems[ItemCategory.hat.rawValue] = "hat_star_crown"
        state.characters[3].equippedColors["hat_star_crown"] = PastelPalette.roseSoft
        state.characters[3].addStroke(
            PaintStroke(
                zone: .belly,
                tool: .solid,
                color: PastelPalette.mintGreen,
                brushWidthNormalized: 0.05,
                normalizedPoints: [CodablePoint(x: 0.5, y: 0.6)]
            )
        )
        service.save(state)

        let reloaded = service.load()
        XCTAssertEqual(reloaded.activeSlotIndex, 3)
        XCTAssertEqual(reloaded.characters[3].equippedItems[ItemCategory.hat.rawValue], "hat_star_crown")
        XCTAssertEqual(reloaded.characters[3].equippedColors["hat_star_crown"], PastelPalette.roseSoft)
        XCTAssertEqual(reloaded.characters[3].strokes(for: .belly).count, 1)
    }

    func testLayerCompositorFixedZOrder() {
        var character = CloudDragonCharacter.defaultDragon
        character.equippedItems[ItemCategory.wingsDeco.rawValue] = "wings_sparkle"
        character.equippedItems[ItemCategory.robe.rawValue] = "robe_cloud_cape"
        character.equippedItems[ItemCategory.glasses.rawValue] = "glasses_star"
        character.equippedItems[ItemCategory.scarf.rawValue] = "scarf_ribbon"
        character.equippedItems[ItemCategory.hat.rawValue] = "hat_star_crown"

        let layers = LayerCompositor.orderedLayers(for: character)
        XCTAssertEqual(layers, layers.sorted())
        XCTAssertLessThan(layers.firstIndex(of: .backWingsDeco) ?? 99, layers.firstIndex(of: .body) ?? 0)
        XCTAssertLessThan(layers.firstIndex(of: .body) ?? 99, layers.firstIndex(of: .belly) ?? 0)
        XCTAssertLessThan(layers.firstIndex(of: .belly) ?? 99, layers.firstIndex(of: .robe) ?? 0)
        XCTAssertLessThan(layers.firstIndex(of: .face) ?? 99, layers.firstIndex(of: .glasses) ?? 0)
        XCTAssertLessThan(layers.firstIndex(of: .scarf) ?? 99, layers.firstIndex(of: .hat) ?? 0)
    }

    func testCatalogMeets80PercentFreeRequirement() {
        let items = CatalogLoader.fallbackCatalog
        let freeCount = items.filter(\.isFree).count
        XCTAssertGreaterThanOrEqual(Double(freeCount) / Double(items.count), 0.80)
    }

    func testPaintMaskNeverSpillsOutsideWingRegion() {
        let giantStroke = PaintStroke(
            zone: .wings,
            tool: .solid,
            color: PastelPalette.roseSoft,
            brushWidthNormalized: 0.45,
            normalizedPoints: [
                CodablePoint(x: 0.05, y: 0.05),
                CodablePoint(x: 0.50, y: 0.50),
                CodablePoint(x: 0.95, y: 0.95),
                CodablePoint(x: 0.14, y: 0.28)
            ]
        )

        guard let cgImage = MaskedBrushRenderer.renderImage(strokes: [giantStroke], onlyZone: .wings, size: 320) else {
            XCTFail("Expected rendered CGImage")
            return
        }

        XCTAssertEqual(alphaAt(x: 16, y: 16, in: cgImage), 0, "Paint must never spill into sky")
        XCTAssertEqual(alphaAt(x: 160, y: 160, in: cgImage), 0, "Wing paint must not spill onto torso")
        XCTAssertGreaterThan(alphaAt(x: 52, y: 80, in: cgImage), 0, "Paint should appear inside left wing")
    }

    func testUnlimitedUndoRedoAndClearPerPart() {
        var character = CloudDragonCharacter.defaultDragon
        for i in 0..<15 {
            character.addStroke(
                PaintStroke(
                    zone: .belly,
                    tool: .solid,
                    color: PastelPalette.mintGreen,
                    brushWidthNormalized: 0.05,
                    normalizedPoints: [CodablePoint(x: 0.5, y: 0.55 + CGFloat(i) * 0.01)]
                )
            )
        }
        XCTAssertEqual(character.strokes(for: .belly).count, 15)
        XCTAssertTrue(character.undo(zone: .belly))
        XCTAssertEqual(character.strokes(for: .belly).count, 14)
        XCTAssertTrue(character.redo(zone: .belly))
        XCTAssertEqual(character.strokes(for: .belly).count, 15)
        character.clear(zone: .belly)
        XCTAssertEqual(character.strokes(for: .belly).count, 0)
    }

    @MainActor
    func testKidsSafeAdCooldownAndRules() {
        let adService = MockAdService()
        let t0 = Date(timeIntervalSince1970: 1_000)

        XCTAssertFalse(adService.canPresentTransitionInterstitial(isPremium: true, isPainting: false, now: t0))
        XCTAssertFalse(adService.canPresentTransitionInterstitial(isPremium: false, isPainting: true, now: t0))
        XCTAssertTrue(adService.presentTransitionInterstitialIfAllowed(isPremium: false, isPainting: false, now: t0))

        // Within 3 minutes (< 180s): blocked
        XCTAssertFalse(adService.canPresentTransitionInterstitial(isPremium: false, isPainting: false, now: t0.addingTimeInterval(120)))
        // After 3 minutes (>= 180s): allowed
        XCTAssertTrue(adService.canPresentTransitionInterstitial(isPremium: false, isPainting: false, now: t0.addingTimeInterval(180)))
    }

    func testParentalGateChallengeMath() {
        let gate = ParentalGateChallenge.generate()
        XCTAssertEqual(gate.expectedAnswer, gate.left * gate.right)
        XCTAssertGreaterThanOrEqual(gate.left, 4)
        XCTAssertLessThanOrEqual(gate.left, 9)
    }

    private func alphaAt(x: Int, y: Int, in image: CGImage) -> UInt8 {
        guard let provider = image.dataProvider,
              let data = provider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return 0
        }
        let offset = y * image.bytesPerRow + x * 4 + 3
        return bytes[offset]
    }
}
