import Foundation

struct WeatherBackgroundCatalogSnapshot: Codable, Equatable {
    let variant: String
    let scenes: [WeatherBackgroundSnapshotRepresentation]
}
