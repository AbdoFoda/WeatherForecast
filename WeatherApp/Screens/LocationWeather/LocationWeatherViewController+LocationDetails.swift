import CoreLocation
import MapKit
import UIKit
import WeatherCore

extension LocationWeatherViewController {
    func loadInitialWeather() {
        switch locationSource {
        case .device:
            deviceLocationManager?.requestLocation()
        case .saved(let location):
            currentLatitude = location.lat
            currentLongitude = location.lon
            viewModel.updateLocationDetails(
                LocationDetails(postalCode: location.postalCode, altitudeMeters: location.altitude)
            )
            resolveSavedLocationDetails(for: location)
            weatherTask?.cancel()
            weatherTask = Task { [weak self] in
                await self?.viewModel.loadWeather(lat: location.lat, lon: location.lon)
            }
        }
    }

    private func resolveSavedLocationDetails(for location: LocationModel) {
        guard location.postalCode == nil else { return }

        locationDetailsTask?.cancel()
        locationDetailsTask = Task { [weak self] in
            guard let self else { return }
            let postalCode = await self.lookupPostalCode(for: location)
            guard !Task.isCancelled, let postalCode else { return }
            await MainActor.run {
                self.viewModel.updateLocationDetails(
                    LocationDetails(postalCode: postalCode, altitudeMeters: nil)
                )
            }
        }
    }

    private func lookupPostalCode(for location: LocationModel) async -> String? {
        let clLocation = CLLocation(latitude: location.lat, longitude: location.lon)

        if let placemarks = try? await geocoder.reverseGeocodeLocation(clLocation),
           let postalCode = placemarks.first?.postalCode,
           !postalCode.isEmpty {
            return postalCode
        }

        let query = [location.name, location.country].compactMap { $0 }.joined(separator: ", ")
        guard !query.isEmpty else { return nil }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: clLocation.coordinate,
            latitudinalMeters: 50_000,
            longitudinalMeters: 50_000
        )
        request.resultTypes = [.address]

        guard let response = try? await MKLocalSearch(request: request).start() else { return nil }
        return response.mapItems.compactMap(\.placemark.postalCode).first { !$0.isEmpty }
    }

    func resolveDeviceLocationDetails(for location: CLLocation) {
        let altitude = Self.resolvedAltitude(from: location)
        if let altitude {
            viewModel.updateLocationDetails(LocationDetails(postalCode: nil, altitudeMeters: altitude))
        }

        locationDetailsTask?.cancel()
        locationDetailsTask = Task { [weak self] in
            guard let self else { return }
            let postalCode: String?
            if let placemarks = try? await self.geocoder.reverseGeocodeLocation(location) {
                postalCode = placemarks.first?.postalCode
            } else {
                postalCode = nil
            }
            guard !Task.isCancelled else { return }
            let details = LocationDetails(postalCode: postalCode, altitudeMeters: altitude)
            guard !details.isEmpty else { return }
            await MainActor.run {
                self.viewModel.updateLocationDetails(details)
            }
        }
    }

    private static func resolvedAltitude(from location: CLLocation?) -> Double? {
        guard let location, location.verticalAccuracy > 0 else { return nil }
        return location.altitude
    }
}
