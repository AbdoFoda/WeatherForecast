@testable import WeatherCore

final class MockLocationSearchProvider: LocationSearchProviding, @unchecked Sendable {
    var results: [LocationModel] = []
    var error: Error?
    private(set) var searchCallCount = 0

    func search(query: String) async throws -> [LocationModel] {
        searchCallCount += 1
        if let error { throw error }
        return results
    }
}
