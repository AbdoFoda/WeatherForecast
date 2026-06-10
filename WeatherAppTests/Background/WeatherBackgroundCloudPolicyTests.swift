import XCTest
import WeatherCore
@testable import WeatherApp

final class WeatherBackgroundCloudPolicyTests: XCTestCase {
    func test_isWideLayout_usesLayoutThreshold() {
        let threshold = WeatherBackgroundConstants.Layout.wideCloudLayoutMinWidth
        XCTAssertFalse(WeatherBackgroundCloudPolicy.isWideLayout(width: threshold))
        XCTAssertTrue(WeatherBackgroundCloudPolicy.isWideLayout(width: threshold + 1))
    }

    func test_density_cloudyScene_usesMinimumFloor() {
        let density = WeatherBackgroundCloudPolicy.density(scene: .cloudy, cloudCoveragePercent: 0)
        XCTAssertGreaterThanOrEqual(
            density,
            WeatherBackgroundConstants.Cloud.Density.fogCloudyFloor
        )
    }

    func test_adjustedLayerDensity_backLayer_isLowerThanFrontBase() {
        let base: CGFloat = 1
        let back = WeatherBackgroundCloudPolicy.adjustedLayerDensity(base, wide: false, layer: .back)
        let front = WeatherBackgroundCloudPolicy.adjustedLayerDensity(base, wide: false, layer: .front)
        XCTAssertGreaterThan(back, front)
    }
}
