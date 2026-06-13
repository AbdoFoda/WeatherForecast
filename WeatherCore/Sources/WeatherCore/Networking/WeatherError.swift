import Foundation

public enum WeatherError: Error, Equatable, Sendable {
    case offline
    case transport
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
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
             .internationalRoamingOff:
            return true
        default:
            return false
        }
    }
}
