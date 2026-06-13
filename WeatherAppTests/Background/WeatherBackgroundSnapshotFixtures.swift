import CoreGraphics
import WeatherCore
@testable import WeatherApp

enum WeatherBackgroundSnapshotFixtures {
    enum DeviceVariant: CaseIterable {
        case iPhone
        case iPad

        var canvasSize: CGSize {
            switch self {
            case .iPhone:
                return CGSize(width: 390, height: 844)
            case .iPad:
                return CGSize(width: 1194, height: 834)
            }
        }

        var catalogCellSize: CGSize {
            switch self {
            case .iPhone:
                return CGSize(width: 124, height: 200)
            case .iPad:
                return CGSize(width: 180, height: 220)
            }
        }

        var snapshotName: String {
            switch self {
            case .iPhone:
                return "iPhone"
            case .iPad:
                return "iPad"
            }
        }
    }

    @MainActor
    static func catalogSnapshot(for variant: DeviceVariant) -> WeatherBackgroundCatalogSnapshot {
        WeatherBackgroundCatalogSnapshot(
            variant: variant.snapshotName,
            scenes: previewScenes.map { scene in
                let view = WeatherBackgroundView(
                    frame: CGRect(origin: .zero, size: variant.canvasSize)
                )
                view.configureForSnapshot(with: configuration(for: scene))
                view.layoutIfNeeded()
                return view.snapshotRepresentation()
            }
        )
    }

    static let previewScenes: [WeatherScene] = [
        .clearDay,
        .clearNight,
        .partlyCloudyDay,
        .partlyCloudyNight,
        .cloudy,
        .fog,
        .drizzle,
        .rain,
        .thunderstorm,
        .snow,
        .neutral,
        .unknown
    ]

    private static let configurationParameters: [WeatherScene: (cloud: Int, wind: Double)] = [
        .neutral: (0, 0),
        .clearDay: (5, 2),
        .clearNight: (5, 2),
        .partlyCloudyDay: (35, 4),
        .partlyCloudyNight: (35, 4),
        .cloudy: (85, 5),
        .fog: (100, 1),
        .drizzle: (70, 3),
        .rain: (85, 8),
        .thunderstorm: (95, 12),
        .snow: (90, 4),
        .unknown: (0, 0)
    ]

    static func configuration(for scene: WeatherScene) -> WeatherBackgroundConfiguration {
        let parameters = configurationParameters[scene] ?? (cloud: 0, wind: 0)
        return WeatherBackgroundConfiguration(
            scene: scene,
            cloudCoveragePercent: parameters.cloud,
            windSpeedMetersPerSecond: parameters.wind
        )
    }
}
