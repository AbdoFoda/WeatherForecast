import Foundation

public protocol HTTPClientProtocol: Sendable {
    func data(for endpoint: Endpoint) async throws -> Data
}
