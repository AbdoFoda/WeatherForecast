#if DEBUG
import Foundation
import WeatherCore

actor UITestLocationSearchService: LocationSearchProviding {
    func search(query: String) async throws -> [LocationModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return UITestWeatherFixtures.searchResults(matching: trimmed)
    }
}
#endif
