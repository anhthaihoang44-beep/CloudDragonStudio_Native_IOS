import XCTest

final class CloudDragonStudioUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFullSixAreasWalkthroughAndScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        } else {
            XCUIDevice.shared.orientation = .portrait
        }
        app.launch()

        // 1. Hub
        let scaleBtn = app.buttons["nav.scaleStudio"]
        XCTAssertTrue(scaleBtn.waitForExistence(timeout: 10))
        attachScreenshot(named: "01_hub")

        // 2. Scale Studio
        scaleBtn.tap()
        let backBtn = app.buttons["nav.backHome"]
        XCTAssertTrue(backBtn.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(backBtn.frame.width, 44.0)
        XCTAssertGreaterThanOrEqual(backBtn.frame.height, 44.0)
        let scaleCanvas = app.otherElements["scale.canvas"].firstMatch
        if scaleCanvas.waitForExistence(timeout: 3) {
            scaleCanvas.coordinate(withNormalizedOffset: CGVector(dx: 0.44, dy: 0.55))
                .press(forDuration: 0.05, thenDragTo: scaleCanvas.coordinate(withNormalizedOffset: CGVector(dx: 0.56, dy: 0.65)))
        }
        attachScreenshot(named: "02_scale_studio")
        backBtn.tap()

        // 3. Wardrobe
        let wardrobeBtn = app.buttons["nav.wardrobe"]
        XCTAssertTrue(wardrobeBtn.waitForExistence(timeout: 5))
        wardrobeBtn.tap()
        let crownBtn = app.buttons["wardrobe.item.hat_star_crown"]
        if crownBtn.waitForExistence(timeout: 4) {
            crownBtn.tap()
        }
        attachScreenshot(named: "03_wardrobe")
        app.buttons["nav.backHome"].tap()

        // 4. Cloud Bath
        let bathBtn = app.buttons["nav.cloudBath"]
        XCTAssertTrue(bathBtn.waitForExistence(timeout: 5))
        bathBtn.tap()
        let bathStage = app.otherElements["bath.stage"].firstMatch
        if bathStage.waitForExistence(timeout: 4) {
            bathStage.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.45))
                .press(forDuration: 0.05, thenDragTo: bathStage.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.55)))
        }
        attachScreenshot(named: "04_cloud_bath")
        app.buttons["nav.backHome"].tap()

        // 5. Bake Nook
        let bakeBtn = app.buttons["nav.bakeNook"]
        XCTAssertTrue(bakeBtn.waitForExistence(timeout: 5))
        bakeBtn.tap()
        let bakeTray = app.otherElements["bake.tray"].firstMatch
        if bakeTray.waitForExistence(timeout: 4) {
            bakeTray.coordinate(withNormalizedOffset: CGVector(dx: 0.45, dy: 0.48)).tap()
            bakeTray.coordinate(withNormalizedOffset: CGVector(dx: 0.55, dy: 0.52)).tap()
        }
        attachScreenshot(named: "05_bake_nook")
        app.buttons["nav.backHome"].tap()

        // 6. Pet Garden
        let petBtn = app.buttons["nav.petGarden"]
        XCTAssertTrue(petBtn.waitForExistence(timeout: 5))
        petBtn.tap()
        let petAct = app.buttons["pet.act.petting"]
        if petAct.waitForExistence(timeout: 4) {
            petAct.tap()
        }
        attachScreenshot(named: "06_pet_garden")
        app.buttons["nav.backHome"].tap()

        // 7. Photo Booth
        let photoBtn = app.buttons["nav.photoBooth"]
        XCTAssertTrue(photoBtn.waitForExistence(timeout: 5))
        photoBtn.tap()
        let snapBtn = app.buttons["photo.snapButton"]
        if snapBtn.waitForExistence(timeout: 4) {
            snapBtn.tap()
        }
        attachScreenshot(named: "07_photo_booth")
        app.buttons["nav.backHome"].tap()
        XCTAssertTrue(scaleBtn.waitForExistence(timeout: 5))
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
