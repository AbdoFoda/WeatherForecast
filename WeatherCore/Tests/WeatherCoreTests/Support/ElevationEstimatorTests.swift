import XCTest
@testable import WeatherCore

final class ElevationEstimatorTests: XCTestCase {
    func test_metersAboveSeaLevel_usesSeaAndGroundPressure() {
        let elevation = ElevationEstimator.metersAboveSeaLevel(
            seaLevelHPa: 1013,
            groundLevelHPa: 1009,
            fallbackSeaLevelHPa: nil
        )

        XCTAssertNotNil(elevation)
        XCTAssertEqual(elevation ?? -1, 33, accuracy: 2)
    }

    func test_metersAboveSeaLevel_fallsBackToPressureField() {
        let elevation = ElevationEstimator.metersAboveSeaLevel(
            seaLevelHPa: nil,
            groundLevelHPa: 1009,
            fallbackSeaLevelHPa: 1013
        )

        XCTAssertNotNil(elevation)
        XCTAssertEqual(elevation ?? -1, 33, accuracy: 2)
    }

    func test_metersAboveSeaLevel_returnsZeroAtSeaLevel() {
        let elevation = ElevationEstimator.metersAboveSeaLevel(
            seaLevelHPa: 1013,
            groundLevelHPa: 1013,
            fallbackSeaLevelHPa: nil
        )

        XCTAssertEqual(elevation ?? -1, 0, accuracy: 0.5)
    }

    func test_metersAboveSeaLevel_returnsNilWithoutGroundPressure() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: 1013,
                groundLevelHPa: nil,
                fallbackSeaLevelHPa: 1013
            )
        )
    }
}
