import CoreGraphics
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

    func testPaintMaskNeverSpillsOutsideWingRegion() {
        let giantStroke = PaintStroke(
            zone: .wings,
            tool: .solid,
            color: PastelPalette.coralBlush,
            brushWidthNormalized: 0.45,
            normalizedPoints: [
                CodablePoint(x: 0.05, y: 0.05),
                CodablePoint(x: 0.50, y: 0.50),
                CodablePoint(x: 0.95, y: 0.95),
                CodablePoint(x: 0.15, y: 0.48)
            ]
        )

        guard let cgImage = MaskedBrushRenderer.renderImage(strokes: [giantStroke], onlyZone: .wings, size: 320) else {
            XCTFail("Expected rendered CGImage")
            return
        }

        XCTAssertEqual(alphaAt(x: 16, y: 16, in: cgImage), 0, "Paint must never spill into sky outside wing mask")
        XCTAssertEqual(alphaAt(x: 160, y: 160, in: cgImage), 0, "Wing paint must not spill onto center torso")
        XCTAssertGreaterThan(alphaAt(x: 64, y: 148, in: cgImage), 0, "Paint should appear inside left wing")
    }

    func testUnlimitedUndoRedoAndClearHistory() {
        var history = PaintHistoryState()
        XCTAssertFalse(history.canUndo)
        XCTAssertFalse(history.canRedo)

        for i in 0..<15 {
            history.commit(
                PaintStroke(
                    zone: .scales,
                    tool: .solid,
                    color: PastelPalette.mint,
                    brushWidthNormalized: 0.05,
                    normalizedPoints: [CodablePoint(x: 0.5, y: 0.4 + CGFloat(i) * 0.01)]
                )
            )
        }
        XCTAssertEqual(history.currentStrokes.count, 15)
        XCTAssertTrue(history.canUndo)

        history.clear()
        XCTAssertEqual(history.currentStrokes.count, 0)
        XCTAssertTrue(history.canUndo)

        history.undo()
        XCTAssertEqual(history.currentStrokes.count, 15)
        XCTAssertTrue(history.canRedo)

        history.undo()
        XCTAssertEqual(history.currentStrokes.count, 14)

        history.redo()
        XCTAssertEqual(history.currentStrokes.count, 15)
    }

    private func alphaAt(x: Int, y: Int, in image: CGImage) -> UInt8 {
        guard let provider = image.dataProvider,
              let data = provider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return 0
        }
        let bpr = image.bytesPerRow
        let offset = y * bpr + x * 4 + 3
        return bytes[offset]
    }
}
