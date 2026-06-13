import XCTest

final class WeatherFlowsUITests: XCTestCase {
    private let timeout: TimeInterval = 15

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_coldLaunch_showsCurrentLocationAndDetail() {
        let app = launchApp()

        XCTAssertTrue(
            app.tables[AccessibilityIdentifier.Locations.table].waitForExistence(timeout: timeout)
        )
        XCTAssertTrue(
            app.cells[AccessibilityIdentifier.Locations.currentCell].waitForExistence(timeout: timeout)
        )
        XCTAssertTrue(app.staticTexts["Cupertino, US"].waitForExistence(timeout: timeout))
    }

    func test_selectSavedCity_updatesDetail() {
        let app = launchApp()

        let cairoCell = app.cells[AccessibilityIdentifier.Locations.cell(id: "cairo")]
        XCTAssertTrue(cairoCell.waitForExistence(timeout: timeout))
        cairoCell.tap()

        XCTAssertTrue(app.staticTexts["Cairo, EG"].waitForExistence(timeout: timeout))
    }

    func test_addLocation_appearsInList() {
        let app = launchApp()

        app.buttons[AccessibilityIdentifier.Locations.addButton].tap()

        let searchField = app.searchFields[AccessibilityIdentifier.AddLocation.searchField]
        XCTAssertTrue(searchField.waitForExistence(timeout: timeout))
        searchField.tap()
        searchField.typeText("Paris")

        let result = app.cells[AccessibilityIdentifier.AddLocation.result(id: "paris")]
        XCTAssertTrue(result.waitForExistence(timeout: timeout))
        result.tap()

        let parisCell = app.cells[AccessibilityIdentifier.Locations.cell(id: "paris")]
        XCTAssertTrue(parisCell.waitForExistence(timeout: timeout))
    }

    func test_pullToRefresh_keepsDetailContent() {
        let app = launchApp()

        let city = app.staticTexts["Cupertino, US"]
        XCTAssertTrue(city.waitForExistence(timeout: timeout))

        let start = city.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
        let finish = start.withOffset(CGVector(dx: 0, dy: 420))
        start.press(forDuration: 0.1, thenDragTo: finish)

        XCTAssertTrue(app.staticTexts["Cupertino, US"].waitForExistence(timeout: timeout))
    }

    func test_offlineMode_showsBanner() {
        let app = launchApp(offline: true)

        let banner = app.otherElements[AccessibilityIdentifier.Banner.offline]
        XCTAssertTrue(banner.waitForExistence(timeout: timeout))
    }

    private func launchApp(offline: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(UITestLaunchArgument.enabled)
        if offline {
            app.launchArguments.append(UITestLaunchArgument.offline)
        }
        app.launch()
        return app
    }
}
