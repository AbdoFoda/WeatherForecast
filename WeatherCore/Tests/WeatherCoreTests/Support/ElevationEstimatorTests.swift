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

    func test_metersAboveSeaLevel_returnsNilWhenGroundPressureIsZero() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: 1013,
                groundLevelHPa: 0,
                fallbackSeaLevelHPa: nil
            )
        )
    }

    func test_metersAboveSeaLevel_returnsNilWhenGroundPressureIsNegative() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: 1013,
                groundLevelHPa: -1,
                fallbackSeaLevelHPa: nil
            )
        )
    }

    func test_metersAboveSeaLevel_returnsNilWhenGroundExceedsSeaLevel() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: 1000,
                groundLevelHPa: 1005,
                fallbackSeaLevelHPa: nil
            )
        )
    }

    func test_metersAboveSeaLevel_returnsNilWithoutSeaOrFallbackPressure() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: nil,
                groundLevelHPa: 1009,
                fallbackSeaLevelHPa: nil
            )
        )
    }

    func test_metersAboveSeaLevel_returnsNilWhenSeaLevelIsZero() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: 0,
                groundLevelHPa: 1009,
                fallbackSeaLevelHPa: nil
            )
        )
    }

    func test_metersAboveSeaLevel_returnsNilWhenFallbackPressureIsZero() {
        XCTAssertNil(
            ElevationEstimator.metersAboveSeaLevel(
                seaLevelHPa: nil,
                groundLevelHPa: 1009,
                fallbackSeaLevelHPa: 0
            )
        )
    }

    func test_metersAboveSeaLevel_fromMainWeather_usesSeaAndGroundFields() {
        let main = MainWeather(
            temp: 20,
            feelsLike: 20,
            tempMin: 18,
            tempMax: 22,
            pressure: 1013,
            seaLevel: 1013,
            grndLevel: 1009,
            humidity: 50
        )

        let elevation = ElevationEstimator.metersAboveSeaLevel(from: main)

        XCTAssertNotNil(elevation)
        XCTAssertEqual(elevation ?? -1, 33, accuracy: 2)
    }

    func test_metersAboveSeaLevel_fromMainWeather_fallsBackToPressureWhenSeaLevelMissing() {
        let main = MainWeather(
            temp: 20,
            feelsLike: 20,
            tempMin: 18,
            tempMax: 22,
            pressure: 1013,
            seaLevel: nil,
            grndLevel: 1009,
            humidity: 50
        )

        let elevation = ElevationEstimator.metersAboveSeaLevel(from: main)

        XCTAssertNotNil(elevation)
        XCTAssertEqual(elevation ?? -1, 33, accuracy: 2)
    }
}
