import Foundation

public enum WeatherError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not construct a valid request URL."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let code):
            return "Server error (HTTP \(code))."
        case .decodingFailed(let error):
            return "Failed to parse weather data: \(error.localizedDescription)"
        }
    }
}
