import CoreGraphics
import Foundation

enum WeatherBackgroundConstants {
    static let gradientCrossfadeDuration: TimeInterval = 0.6
    static let parallaxDuration: TimeInterval = 48
    static let celestialPulseDuration: TimeInterval = 4

    enum Wind {
        static let driftFactor: CGFloat = 12
        static let maxDrift: CGFloat = 80
    }

    enum Cloud {
        static let minCoverageToShow = 15
        static let maxOpacity: Float = 0.55
    }

    enum Particle {
        static let baseRainBirthRate: Float = 180
        static let baseSnowBirthRate: Float = 90
        static let drizzleMultiplier: Float = 0.55
        static let stormMultiplier: Float = 1.35
    }
}
