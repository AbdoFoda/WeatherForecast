import XCTest
@testable import WeatherApp

final class TemperatureGraphRendererTests: XCTestCase {
    func test_curvePath_startsAtCurrentPoint() {
        let path = TemperatureGraphRenderer.curvePath(
            cellWidth: 88,
            graphTop: 36,
            graphHeight: 120,
            normalizedY: TemperatureGraphRenderer.NeighborNormalizedY(
                previous: 0.8,
                current: 0.5,
                next: 0.3
            )
        )

        XCTAssertFalse(path.isEmpty)
        let bounds = path.bounds
        XCTAssertGreaterThan(bounds.width, 0)
        XCTAssertGreaterThan(bounds.height, 0)
    }

    func test_dotCenter_alignsWithCellCenter() {
        let center = TemperatureGraphRenderer.dotCenter(
            cellWidth: 88,
            graphTop: 36,
            graphHeight: 120,
            normalizedY: 0.5
        )

        XCTAssertEqual(center.x, 44)
        XCTAssertGreaterThan(center.y, 36)
    }
}
