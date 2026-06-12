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
        .unknown,
    ]

    static func configuration(for scene: WeatherScene) -> WeatherBackgroundConfiguration {
        switch scene {
        case .neutral:
            return WeatherBackgroundConfiguration(
                scene: .neutral,
                cloudCoveragePercent: 0,
                windSpeedMetersPerSecond: 0
            )
        case .clearDay:
            return WeatherBackgroundConfiguration(
                scene: .clearDay,
                cloudCoveragePercent: 5,
                windSpeedMetersPerSecond: 2
            )
        case .clearNight:
            return WeatherBackgroundConfiguration(
                scene: .clearNight,
                cloudCoveragePercent: 5,
                windSpeedMetersPerSecond: 2
            )
        case .partlyCloudyDay:
            return WeatherBackgroundConfiguration(
                scene: .partlyCloudyDay,
                cloudCoveragePercent: 35,
                windSpeedMetersPerSecond: 4
            )
        case .partlyCloudyNight:
            return WeatherBackgroundConfiguration(
                scene: .partlyCloudyNight,
                cloudCoveragePercent: 35,
                windSpeedMetersPerSecond: 4
            )
        case .cloudy:
            return WeatherBackgroundConfiguration(
                scene: .cloudy,
                cloudCoveragePercent: 85,
                windSpeedMetersPerSecond: 5
            )
        case .fog:
            return WeatherBackgroundConfiguration(
                scene: .fog,
                cloudCoveragePercent: 100,
                windSpeedMetersPerSecond: 1
            )
        case .drizzle:
            return WeatherBackgroundConfiguration(
                scene: .drizzle,
                cloudCoveragePercent: 70,
                windSpeedMetersPerSecond: 3
            )
        case .rain:
            return WeatherBackgroundConfiguration(
                scene: .rain,
                cloudCoveragePercent: 85,
                windSpeedMetersPerSecond: 8
            )
        case .thunderstorm:
            return WeatherBackgroundConfiguration(
                scene: .thunderstorm,
                cloudCoveragePercent: 95,
                windSpeedMetersPerSecond: 12
            )
        case .snow:
            return WeatherBackgroundConfiguration(
                scene: .snow,
                cloudCoveragePercent: 90,
                windSpeedMetersPerSecond: 4
            )
        case .unknown:
            return WeatherBackgroundConfiguration(
                scene: .unknown,
                cloudCoveragePercent: 0,
                windSpeedMetersPerSecond: 0
            )
        }
    }
}
