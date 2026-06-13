#if DEBUG
import Foundation
import WeatherCore

final class UITestLocationSearchService: LocationSearchProviding, @unchecked Sendable {
    func search(query: String) async throws -> [LocationModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return UITestWeatherFixtures.searchResults(matching: trimmed)
    }
}
#endif
