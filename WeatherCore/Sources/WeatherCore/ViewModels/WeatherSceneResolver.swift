import Foundation

public enum WeatherSceneResolver {
    public static func resolve(from weather: CurrentWeatherResponse) -> WeatherScene {
        let condition = weather.weather.first
        let conditionID = condition?.id ?? 0
        let isNight = condition?.icon.hasSuffix("n") ?? false
        let cloudCoverage = weather.clouds?.all ?? 0

        if weather.snow != nil || (600...699).contains(conditionID) {
            return .snow
        }
        if (200...299).contains(conditionID) {
            return .thunderstorm
        }
        if (300...399).contains(conditionID) {
            return .drizzle
        }
        if weather.rain != nil || (500...599).contains(conditionID) {
            return .rain
        }
        if (700...799).contains(conditionID) {
            return .fog
        }
        if conditionID == 800 {
            return isNight ? .clearNight : .clearDay
        }
        if conditionID == 801 || conditionID == 802 {
            return isNight ? .partlyCloudyNight : .partlyCloudyDay
        }
        if conditionID == 803 || conditionID == 804 || cloudCoverage >= WeatherConstants.Scene.heavyCloudThreshold {
            return .cloudy
        }

        return .unknown
    }
}
