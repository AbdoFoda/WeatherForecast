import Foundation

public enum WeatherIconURL {
    public static func make(iconID: String?) -> URL? {
        let id = iconID ?? WeatherConstants.Icon.fallbackIconID
        return URL(string: WeatherConstants.Icon.baseURL + id + WeatherConstants.Icon.scaleSuffix)
    }
}
