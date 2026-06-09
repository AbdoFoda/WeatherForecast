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
        let (data, response) = try await session.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw WeatherError.httpError(statusCode: http.statusCode)
        }
        
        return data
    }
}
