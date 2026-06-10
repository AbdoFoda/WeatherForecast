import Foundation

public struct Endpoint: Sendable {
    public let path: String
    public let queryItems: [URLQueryItem]

    public func url(baseURL: URL) throws -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        return url
    }
}

public extension Endpoint {
    static func currentWeather(lat: Double, lon: Double) -> Endpoint {
        coordinateEndpoint(route: .current, lat: lat, lon: lon)
    }

    static func forecast(
        lat: Double,
        lon: Double,
        count: Int = WeatherAPI.Defaults.forecastItemCount
    ) -> Endpoint {
        Endpoint(
            path: WeatherAPI.Route.forecast.rawValue,
            queryItems: coordinateQueryItems(lat: lat, lon: lon) + [
                URLQueryItem(name: WeatherAPI.QueryKey.cnt.rawValue, value: String(count)),
            ]
        )
    }

    static func airPollution(lat: Double, lon: Double) -> Endpoint {
        coordinateEndpoint(route: .airPollution, lat: lat, lon: lon)
    }

    static func geocodingDirect(
        query: String,
        limit: Int = WeatherAPI.Defaults.geocodingDirectLimit
    ) -> Endpoint {
        Endpoint(
            path: WeatherAPI.Route.geocodingDirect.rawValue,
            queryItems: [
                URLQueryItem(name: WeatherAPI.QueryKey.q.rawValue, value: query),
                URLQueryItem(name: WeatherAPI.QueryKey.limit.rawValue, value: String(limit)),
            ]
        )
    }

    static func geocodingReverse(
        lat: Double,
        lon: Double,
        limit: Int = WeatherAPI.Defaults.geocodingReverseLimit
    ) -> Endpoint {
        Endpoint(
            path: WeatherAPI.Route.geocodingReverse.rawValue,
            queryItems: coordinateQueryItems(lat: lat, lon: lon) + [
                URLQueryItem(name: WeatherAPI.QueryKey.limit.rawValue, value: String(limit)),
            ]
        )
    }

    private static func coordinateEndpoint(route: WeatherAPI.Route, lat: Double, lon: Double) -> Endpoint {
        Endpoint(
            path: route.rawValue,
            queryItems: coordinateQueryItems(lat: lat, lon: lon)
        )
    }

    private static func coordinateQueryItems(lat: Double, lon: Double) -> [URLQueryItem] {
        let format = "%.\(WeatherAPI.Defaults.coordinateDecimalPlaces)f"
        return [
            URLQueryItem(name: WeatherAPI.QueryKey.lat.rawValue, value: String(format: format, lat)),
            URLQueryItem(name: WeatherAPI.QueryKey.lon.rawValue, value: String(format: format, lon)),
        ]
    }
}
