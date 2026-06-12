import Foundation

public protocol LocationSearchProviding: Sendable {
    func search(query: String) async throws -> [LocationModel]
}
