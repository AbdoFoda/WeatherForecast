import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class WeatherBackgroundViewTests: XCTestCase {
    func test_configure_rainScene_enablesParticles() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.layoutIfNeeded()

        sut.configure(with: WeatherBackgroundConfiguration(
            scene: .rain,
            cloudCoveragePercent: 80,
            windSpeedMetersPerSecond: 6
        ))

        XCTAssertTrue(sut.hasActiveParticleEmitter)
        XCTAssertTrue(sut.isCloudParallaxVisible)
        XCTAssertFalse(sut.isCelestialGlowVisible)
    }

    func test_configure_clearDay_showsSunWithoutParticles() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.configure(with: WeatherBackgroundConfiguration(
            scene: .clearDay,
            cloudCoveragePercent: 5,
            windSpeedMetersPerSecond: 2
        ))

        XCTAssertFalse(sut.hasActiveParticleEmitter)
        XCTAssertTrue(sut.isCelestialGlowVisible)
    }

    func test_configure_snowScene_enablesSnowParticles() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.configure(with: WeatherBackgroundConfiguration(
            scene: .snow,
            cloudCoveragePercent: 90,
            windSpeedMetersPerSecond: 3
        ))

        XCTAssertTrue(sut.hasActiveParticleEmitter)
    }

    func test_configure_thunderstorm_enablesRainAndFlashLayer() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.configure(with: WeatherBackgroundConfiguration(
            scene: .thunderstorm,
            cloudCoveragePercent: 95,
            windSpeedMetersPerSecond: 10
        ))

        XCTAssertTrue(sut.hasActiveParticleEmitter)
        XCTAssertTrue(sut.isStormFlashActive)
    }

    func test_sceneTransition_fromRainToClearDay_removesParticles() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.configure(with: WeatherBackgroundConfiguration(
            scene: .rain,
            cloudCoveragePercent: 80,
            windSpeedMetersPerSecond: 5
        ))
        XCTAssertTrue(sut.hasActiveParticleEmitter)

        sut.configure(with: WeatherBackgroundConfiguration(
            scene: .clearDay,
            cloudCoveragePercent: 0,
            windSpeedMetersPerSecond: 2
        ))

        XCTAssertFalse(sut.hasActiveParticleEmitter)
        XCTAssertTrue(sut.isCelestialGlowVisible)
    }

    func test_configure_sameSceneAndEffects_isNoOp() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        let config = WeatherBackgroundConfiguration(
            scene: .clearDay,
            cloudCoveragePercent: 0,
            windSpeedMetersPerSecond: 1
        )
        sut.configure(with: config)
        let layerCount = sut.layer.sublayers?.count
        sut.configure(with: config)
        XCTAssertEqual(sut.layer.sublayers?.count, layerCount)
    }
}
