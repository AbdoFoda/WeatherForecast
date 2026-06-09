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
        Endpoint(
            path: "current",
            queryItems: [
                URLQueryItem(name: "lat", value: String(format: "%.4f", lat)),
                URLQueryItem(name: "lon", value: String(format: "%.4f", lon)),
            ]
        )
    }

    static func forecast(lat: Double, lon: Double, count: Int = 40) -> Endpoint {
        Endpoint(
            path: "forecast",
            queryItems: [
                URLQueryItem(name: "lat", value: String(format: "%.4f", lat)),
                URLQueryItem(name: "lon", value: String(format: "%.4f", lon)),
                URLQueryItem(name: "cnt", value: String(count)),
            ]
        )
    }

    static func airPollution(lat: Double, lon: Double) -> Endpoint {
        Endpoint(
            path: "air",
            queryItems: [
                URLQueryItem(name: "lat", value: String(format: "%.4f", lat)),
                URLQueryItem(name: "lon", value: String(format: "%.4f", lon)),
            ]
        )
    }

    static func geocodingDirect(query: String, limit: Int = 5) -> Endpoint {
        Endpoint(
            path: "geo/direct",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        )
    }

    static func geocodingReverse(lat: Double, lon: Double, limit: Int = 1) -> Endpoint {
        Endpoint(
            path: "geo/reverse",
            queryItems: [
                URLQueryItem(name: "lat", value: String(format: "%.4f", lat)),
                URLQueryItem(name: "lon", value: String(format: "%.4f", lon)),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        )
    }
}
