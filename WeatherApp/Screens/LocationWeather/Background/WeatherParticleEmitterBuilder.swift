import UIKit
import WeatherCore

enum WeatherParticleEmitterBuilder {
    static func makeEmitter(
        for scene: WeatherScene,
        windSpeed: Double,
        bounds: CGRect
    ) -> CAEmitterLayer? {
        switch WeatherBackgroundEffectsPolicy.particleKind(for: scene) {
        case .none:
            return nil
        case .rain:
            return rainEmitter(scene: scene, windSpeed: windSpeed, bounds: bounds)
        case .snow:
            return snowEmitter(windSpeed: windSpeed, bounds: bounds)
        }
    }

    private static func rainEmitter(
        scene: WeatherScene,
        windSpeed: Double,
        bounds: CGRect
    ) -> CAEmitterLayer {
        let emitter = baseEmitter(bounds: bounds)
        let cell = CAEmitterCell()
        cell.contents = WeatherBackgroundAssetFactory.rainDropImage()
        cell.birthRate = rainBirthRate(for: scene)
        cell.lifetime = 1.2
        cell.velocity = 280
        cell.velocityRange = 60
        cell.emissionLongitude = .pi
        cell.scale = 0.12
        cell.scaleRange = 0.04
        cell.alphaRange = 0.2
        applyWind(to: cell, windSpeed: windSpeed)
        emitter.emitterCells = [cell]
        return emitter
    }

    private static func snowEmitter(windSpeed: Double, bounds: CGRect) -> CAEmitterLayer {
        let emitter = baseEmitter(bounds: bounds)
        let cell = CAEmitterCell()
        cell.contents = WeatherBackgroundAssetFactory.snowflakeImage()
        cell.birthRate = WeatherBackgroundConstants.Particle.baseSnowBirthRate
        cell.lifetime = 5
        cell.velocity = 45
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.spin = 0.4
        cell.spinRange = 0.8
        cell.scale = 0.2
        cell.scaleRange = 0.08
        applyWind(to: cell, windSpeed: windSpeed, driftMultiplier: 0.35)
        emitter.emitterCells = [cell]
        return emitter
    }

    private static func baseEmitter(bounds: CGRect) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -8)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        return emitter
    }

    private static func rainBirthRate(for scene: WeatherScene) -> Float {
        var rate = WeatherBackgroundConstants.Particle.baseRainBirthRate
        if scene == .drizzle {
            rate *= WeatherBackgroundConstants.Particle.drizzleMultiplier
        } else if scene == .thunderstorm {
            rate *= WeatherBackgroundConstants.Particle.stormMultiplier
        }
        return rate
    }

    private static func applyWind(
        to cell: CAEmitterCell,
        windSpeed: Double,
        driftMultiplier: CGFloat = 1
    ) {
        let drift = min(
            WeatherBackgroundConstants.Wind.maxDrift,
            CGFloat(windSpeed) * WeatherBackgroundConstants.Wind.driftFactor * driftMultiplier
        )
        cell.xAcceleration = drift
    }
}
