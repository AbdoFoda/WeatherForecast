import Foundation

public enum WeatherAPI {
    public enum Route: String, Sendable {
        case current = "current"
        case forecast = "forecast"
        case airPollution = "air"
        case geocodingDirect = "geo/direct"
        case geocodingReverse = "geo/reverse"
    }

    public enum QueryKey: String, Sendable {
        case lat
        case lon
        case cnt
        case q
        case limit
    }

    public enum Defaults: Sendable {
        public static let forecastItemCount = 40
        public static let geocodingDirectLimit = 5
        public static let geocodingReverseLimit = 1
        public static let coordinateDecimalPlaces = 4
    }
}
