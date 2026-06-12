import Foundation

public enum WeatherAPI {
    public enum Route: String, Sendable {
        case current = "current"
        case forecast = "forecast"
        case airPollution = "air"
    }

    public enum QueryKey: String, Sendable {
        case lat
        case lon
        case cnt
    }

    public enum Defaults: Sendable {
        public static let forecastItemCount = 40
        public static let coordinateDecimalPlaces = 4
    }
}
