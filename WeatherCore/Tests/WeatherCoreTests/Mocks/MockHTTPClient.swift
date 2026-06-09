import Foundation
@testable import WeatherCore

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var result: Result<Data, Error> = .success(Data())
    var capturedEndpoints: [Endpoint] = []
    
    func data(for endpoint: Endpoint) async throws -> Data {
        capturedEndpoints.append(endpoint)
        return try result.get()
    }
}
