import XCTest
import WeatherCore
@testable import WeatherApp

final class WeatherParticleEmitterBuilderTests: XCTestCase {
    func test_makeEmitter_rainScene_returnsEmitter() {
        let emitter = WeatherParticleEmitterBuilder.makeEmitter(
            for: .rain,
            windSpeed: 5,
            bounds: CGRect(x: 0, y: 0, width: 320, height: 640)
        )
        XCTAssertNotNil(emitter)
        XCTAssertFalse(emitter?.emitterCells?.isEmpty ?? true)
    }

    func test_makeEmitter_clearDay_returnsNil() {
        let emitter = WeatherParticleEmitterBuilder.makeEmitter(
            for: .clearDay,
            windSpeed: 2,
            bounds: CGRect(x: 0, y: 0, width: 320, height: 640)
        )
        XCTAssertNil(emitter)
    }

    func test_makeEmitter_windIncreasesDrift() {
        let calm = WeatherParticleEmitterBuilder.makeEmitter(
            for: .rain,
            windSpeed: 1,
            bounds: CGRect(x: 0, y: 0, width: 320, height: 640)
        )
        let windy = WeatherParticleEmitterBuilder.makeEmitter(
            for: .rain,
            windSpeed: 12,
            bounds: CGRect(x: 0, y: 0, width: 320, height: 640)
        )
        let calmDrift = calm?.emitterCells?.first?.xAcceleration ?? 0
        let windyDrift = windy?.emitterCells?.first?.xAcceleration ?? 0
        XCTAssertGreaterThan(windyDrift, calmDrift)
    }
}
