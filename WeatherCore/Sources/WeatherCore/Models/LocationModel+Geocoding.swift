import Foundation

public extension LocationModel {
    static let currentLocationID = "__current_location__"

    static var currentLocation: LocationModel {
        LocationModel(
            id: currentLocationID,
            name: L10n.Locations.currentLocation,
            lat: 0,
            lon: 0,
            country: nil
        )
    }

    var displayTitle: String {
        guard let country, !country.isEmpty else { return name }
        return "\(name), \(country)"
    }

    init(geocodingResult: GeocodingResult) {
        let displayName: String
        if let state = geocodingResult.state, !state.isEmpty {
            displayName = "\(geocodingResult.name), \(state)"
        } else {
            displayName = geocodingResult.name
        }

        self.init(
            id: Self.id(lat: geocodingResult.lat, lon: geocodingResult.lon),
            name: displayName,
            lat: geocodingResult.lat,
            lon: geocodingResult.lon,
            country: geocodingResult.country
        )
    }

    static func id(lat: Double, lon: Double) -> String {
        String(format: "%.4f,%.4f", lat, lon)
    }
}

public enum LocationSelection: Equatable, Sendable {
    case current
    case saved(LocationModel)
}
