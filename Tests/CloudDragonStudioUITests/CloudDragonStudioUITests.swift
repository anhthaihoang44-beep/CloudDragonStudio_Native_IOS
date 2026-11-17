import XCTest

final class CloudDragonStudioUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHomeNavigationAndCaptureScreenshots() throws {
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
        XCTAssertTrue(app.buttons["nav.cloudBath"].exists)
        XCTAssertTrue(app.buttons["nav.wardrobe"].exists)
        XCTAssertTrue(app.buttons["nav.bakeNook"].exists)
        XCTAssertTrue(app.buttons["nav.petGarden"].exists)
        XCTAssertTrue(app.buttons["nav.photoBooth"].exists)

        attachScreenshot(named: "01_home")

        scaleBtn.tap()
        let backBtn = app.buttons["nav.backHome"]
        XCTAssertTrue(backBtn.waitForExistence(timeout: 5), "Top-left Home button must appear")
        XCTAssertGreaterThanOrEqual(backBtn.frame.width, 44.0)
        XCTAssertGreaterThanOrEqual(backBtn.frame.height, 44.0)

        attachScreenshot(named: "02_scale_studio_loop1")

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
