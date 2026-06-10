import WeatherCore

struct WeatherBackgroundConfiguration: Equatable {
    let scene: WeatherScene
    let cloudCoveragePercent: Int
    let windSpeedMetersPerSecond: Double

    static let neutral = WeatherBackgroundConfiguration(
        scene: .neutral,
        cloudCoveragePercent: 0,
        windSpeedMetersPerSecond: 0
    )
}

extension WeatherBackgroundConfiguration {
    init(displayData: LocationWeatherDisplayData) {
        self.init(
            scene: displayData.backgroundScene,
            cloudCoveragePercent: displayData.cloudCoveragePercent,
            windSpeedMetersPerSecond: displayData.windSpeedMetersPerSecond
        )
    }
}
