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
        cell.lifetime = WeatherBackgroundConstants.Particle.rainLifetime
        cell.velocity = WeatherBackgroundConstants.Particle.rainVelocity
        cell.velocityRange = WeatherBackgroundConstants.Particle.rainVelocityRange
        cell.emissionLongitude = .pi
        cell.scale = WeatherBackgroundConstants.Particle.rainScale
        cell.scaleRange = WeatherBackgroundConstants.Particle.rainScaleRange
        cell.alphaRange = WeatherBackgroundConstants.Particle.rainAlphaRange
        applyWind(to: cell, windSpeed: windSpeed)
        emitter.emitterCells = [cell]
        return emitter
    }

    private static func snowEmitter(windSpeed: Double, bounds: CGRect) -> CAEmitterLayer {
        let emitter = baseEmitter(bounds: bounds)
        let cell = CAEmitterCell()
        cell.contents = WeatherBackgroundAssetFactory.snowflakeImage()
        cell.birthRate = WeatherBackgroundConstants.Particle.baseSnowBirthRate
        cell.lifetime = WeatherBackgroundConstants.Particle.snowLifetime
        cell.velocity = WeatherBackgroundConstants.Particle.snowVelocity
        cell.velocityRange = WeatherBackgroundConstants.Particle.snowVelocityRange
        cell.emissionLongitude = .pi
        cell.spin = WeatherBackgroundConstants.Particle.snowSpin
        cell.spinRange = WeatherBackgroundConstants.Particle.snowSpinRange
        cell.scale = WeatherBackgroundConstants.Particle.snowScale
        cell.scaleRange = WeatherBackgroundConstants.Particle.snowScaleRange
        applyWind(
            to: cell,
            windSpeed: windSpeed,
            driftMultiplier: WeatherBackgroundConstants.Particle.snowWindDriftMultiplier
        )
        emitter.emitterCells = [cell]
        return emitter
    }

    private static func baseEmitter(bounds: CGRect) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(
            x: bounds.midX,
            y: WeatherBackgroundConstants.Layout.particleEmitterVerticalOffset
        )
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(
            width: bounds.width,
            height: WeatherBackgroundConstants.Layout.particleEmitterLineHeight
        )
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
