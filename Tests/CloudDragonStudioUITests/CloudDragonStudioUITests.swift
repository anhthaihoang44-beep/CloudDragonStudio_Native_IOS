import XCTest

final class CloudDragonStudioUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHomeAndScaleStudioPaintingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        } else {
            XCUIDevice.shared.orientation = .portrait
        }
        app.launch()

        let scaleBtn = app.buttons["nav.scaleStudio"]
        XCTAssertTrue(scaleBtn.waitForExistence(timeout: 10), "Home Scale Studio button must appear")
        attachScreenshot(named: "01_home")

        scaleBtn.tap()
        let backBtn = app.buttons["nav.backHome"]
        XCTAssertTrue(backBtn.waitForExistence(timeout: 5), "Top-left Home button must appear")
        XCTAssertGreaterThanOrEqual(backBtn.frame.width, 44.0)
        XCTAssertGreaterThanOrEqual(backBtn.frame.height, 44.0)

        let canvas = app.otherElements["scale.canvas"].firstMatch
        let startCoord = canvas.exists
            ? canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.40, dy: 0.45))
            : app.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.35))
        let endCoord = canvas.exists
            ? canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.60, dy: 0.60))
            : app.coordinate(withNormalizedOffset: CGVector(dx: 0.60, dy: 0.45))
        startCoord.press(forDuration: 0.05, thenDragTo: endCoord)

        let wingsBtn = app.buttons["scale.zone.wings"]
        if wingsBtn.waitForExistence(timeout: 3) {
            wingsBtn.tap()
        }
        let rainbowBtn = app.buttons["scale.tool.rainbow"]
        if rainbowBtn.waitForExistence(timeout: 3) {
            rainbowBtn.tap()
        }
        let wingStart = canvas.exists
            ? canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.45))
            : app.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.35))
        let wingEnd = canvas.exists
            ? canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.48))
            : app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.38))
        wingStart.press(forDuration: 0.05, thenDragTo: wingEnd)

        let undoBtn = app.buttons["scale.undo"]
        XCTAssertTrue(undoBtn.waitForExistence(timeout: 3))
        XCTAssertTrue(undoBtn.isEnabled)

        attachScreenshot(named: "02_scale_studio_painted")

        backBtn.tap()
        XCTAssertTrue(scaleBtn.waitForExistence(timeout: 5), "Should return to Home")
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
