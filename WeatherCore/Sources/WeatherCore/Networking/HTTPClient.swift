import Foundation

public final class HTTPClient: HTTPClientProtocol, Sendable {
    private let session: URLSession
    private let baseURL: URL

    public convenience init(baseURL: URL) {
        self.init(session: HTTPClient.makeEphemeralSession(), baseURL: baseURL)
    }

    public init(
        session: URLSession,
        baseURL: URL
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    private static func makeEphemeralSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    public func data(for endpoint: Endpoint) async throws -> Data {
        let url = try endpoint.url(baseURL: baseURL)

        guard url.scheme?.lowercased() == "https" else {
            throw WeatherError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError where error.isConnectivityIssue {
            throw WeatherError.offline
        } catch {
            throw WeatherError.transport
        }

        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw WeatherError.httpError(statusCode: http.statusCode)
        }

        return data
    }
}
