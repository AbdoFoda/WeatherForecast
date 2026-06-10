import XCTest
import WeatherCore
@testable import WeatherApp

final class WeatherBackgroundEffectsPolicyTests: XCTestCase {
    func test_particleKind_rainForStorm() {
        XCTAssertEqual(WeatherBackgroundEffectsPolicy.particleKind(for: .thunderstorm), .rain)
    }

    func test_particleKind_snowForSnowScene() {
        XCTAssertEqual(WeatherBackgroundEffectsPolicy.particleKind(for: .snow), .snow)
    }

    func test_particleKind_noneForClearDay() {
        XCTAssertEqual(WeatherBackgroundEffectsPolicy.particleKind(for: .clearDay), .none)
    }

    func test_celestialKind_sunForClearDay() {
        XCTAssertEqual(WeatherBackgroundEffectsPolicy.celestialKind(for: .clearDay), .sun)
    }

    func test_celestialKind_moonForClearNight() {
        XCTAssertEqual(WeatherBackgroundEffectsPolicy.celestialKind(for: .clearNight), .moon)
    }

    func test_shouldShowClouds_whenCoverageHigh() {
        XCTAssertTrue(WeatherBackgroundEffectsPolicy.shouldShowClouds(scene: .clearDay, cloudCoveragePercent: 40))
    }
}
