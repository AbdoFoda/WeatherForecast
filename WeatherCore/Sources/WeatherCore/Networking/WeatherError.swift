import Foundation

public enum WeatherError: Error, Sendable {
    case offline(underlying: Error)
    case transport(underlying: Error)
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(underlying: Error)
}

public extension WeatherError {
    var isOffline: Bool {
        if case .offline = self { return true }
        return false
    }
}

extension Error {
    var isOfflineWeatherError: Bool {
        if let weatherError = self as? WeatherError {
            return weatherError.isOffline
        }
        if let urlError = self as? URLError {
            return urlError.isConnectivityIssue
        }
        return false
    }
}

extension URLError {
    var isConnectivityIssue: Bool {
        switch code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed,
             .internationalRoamingOff,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}
