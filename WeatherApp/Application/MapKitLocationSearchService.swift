import MapKit
import WeatherCore

final class MapKitLocationSearchService: LocationSearchProviding {
    func search(query: String) async throws -> [LocationModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = [.address, .pointOfInterest]

        let response = try await MKLocalSearch(request: request).start()
        return response.mapItems.compactMap(Self.location(from:))
    }

    private static func location(from item: MKMapItem) -> LocationModel? {
        let placemark = item.placemark
        let coordinate = placemark.coordinate
        guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }

        let name = item.name
            ?? placemark.locality
            ?? placemark.name
            ?? placemark.administrativeArea
        guard let resolvedName = name, !resolvedName.isEmpty else { return nil }

        return LocationModel(
            id: LocationModel.id(lat: coordinate.latitude, lon: coordinate.longitude),
            name: resolvedName,
            lat: coordinate.latitude,
            lon: coordinate.longitude,
            country: placemark.country,
            postalCode: placemark.postalCode,
            altitude: Self.resolvedAltitude(from: placemark.location)
        )
    }

    private static func resolvedAltitude(from location: CLLocation?) -> Double? {
        guard let location, location.verticalAccuracy > 0 else { return nil }
        return location.altitude
    }
}
