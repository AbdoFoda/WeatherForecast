import UIKit

struct WeatherBackgroundSnapshotRepresentation: Codable, Equatable {
    struct Size: Codable, Equatable {
        let width: Double
        let height: Double
    }

    struct Gradient: Codable, Equatable {
        let top: String
        let bottom: String
    }

    struct Effects: Codable, Equatable {
        let showsCloudParallax: Bool
        let cloudOpacity: Double
        let celestialKind: String
        let showsCelestialGlow: Bool
        let showsStormFlash: Bool
        let precipitationOverlay: String?
        let hasParticleEmitter: Bool
    }

    let scene: String
    let cloudCoveragePercent: Int
    let windSpeedMetersPerSecond: Double
    let canvasSize: Size
    let gradient: Gradient
    let effects: Effects
}

struct WeatherBackgroundCatalogSnapshot: Codable, Equatable {
    let variant: String
    let scenes: [WeatherBackgroundSnapshotRepresentation]
}

extension UIColor {
    var rgbaHex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "#%02X%02X%02X",
            Int((red * 255).rounded()),
            Int((green * 255).rounded()),
            Int((blue * 255).rounded())
        )
    }
}
