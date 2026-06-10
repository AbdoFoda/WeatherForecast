import XCTest
@testable import WeatherApp

final class WeatherBackgroundMotionPolicyTests: XCTestCase {
    func test_cloudDrift_increasesWithWindSpeed() {
        let calm = WeatherBackgroundMotionPolicy.cloudDrift(windSpeed: 1)
        let windy = WeatherBackgroundMotionPolicy.cloudDrift(windSpeed: 10)

        XCTAssertGreaterThan(windy.backDistance, calm.backDistance)
        XCTAssertLessThan(windy.duration, calm.duration)
        XCTAssertLessThan(
            windy.duration,
            WeatherBackgroundConstants.Motion.baseCloudDriftDuration
        )
        XCTAssertGreaterThan(
            windy.backDistance,
            WeatherBackgroundConstants.Motion.backCloudDriftBaseDistance
        )
    }

    func test_celestialSway_increasesWithWindSpeed() {
        let calm = WeatherBackgroundMotionPolicy.celestialSwayDistance(windSpeed: 1)
        let windy = WeatherBackgroundMotionPolicy.celestialSwayDistance(windSpeed: 10)

        XCTAssertGreaterThan(windy, calm)
        XCTAssertLessThan(
            WeatherBackgroundMotionPolicy.celestialSwayDuration(windSpeed: 10),
            WeatherBackgroundMotionPolicy.celestialSwayDuration(windSpeed: 1)
        )
    }
}
