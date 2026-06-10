import WeatherCore

enum WeatherBackgroundEffectsPolicy {
    enum ParticleKind {
        case none
        case rain
        case snow
    }

    enum CelestialKind {
        case none
        case sun
        case moon
    }

    static func particleKind(for scene: WeatherScene) -> ParticleKind {
        switch scene {
        case .rain, .drizzle, .thunderstorm:
            return .rain
        case .snow:
            return .snow
        default:
            return .none
        }
    }

    static func celestialKind(for scene: WeatherScene) -> CelestialKind {
        switch scene {
        case .clearDay, .partlyCloudyDay:
            return .sun
        case .clearNight, .partlyCloudyNight:
            return .moon
        default:
            return .none
        }
    }

    static func shouldShowClouds(scene: WeatherScene, cloudCoveragePercent: Int) -> Bool {
        if cloudCoveragePercent >= WeatherBackgroundConstants.Cloud.minCoverageToShow {
            return true
        }
        switch scene {
        case .partlyCloudyDay, .partlyCloudyNight, .cloudy, .fog, .rain, .drizzle, .thunderstorm, .snow:
            return true
        default:
            return false
        }
    }
}
