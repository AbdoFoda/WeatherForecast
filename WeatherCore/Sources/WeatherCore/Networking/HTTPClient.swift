import Foundation

public final class HTTPClient: HTTPClientProtocol, Sendable {
    private let session: URLSession
    private let baseURL: URL

    public init(
        session: URLSession = .shared,
        baseURL: URL
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    public func data(for endpoint: Endpoint) async throws -> Data {
        let url = try endpoint.url(baseURL: baseURL)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError where error.isConnectivityIssue {
            throw WeatherError.offline(underlying: error)
        } catch {
            throw WeatherError.transport(underlying: error)
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
