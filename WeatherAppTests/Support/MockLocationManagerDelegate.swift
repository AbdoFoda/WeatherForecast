import CoreLocation
@testable import WeatherApp

@MainActor
final class MockLocationManagerDelegate: LocationManagerDelegate {
    private(set) var updatedLocations: [CLLocation] = []
    private(set) var errors: [Error] = []
    private(set) var denyCount = 0

    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        updatedLocations.append(location)
    }

    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        errors.append(error)
    }

    func locationManagerDidDenyPermission(_ manager: LocationManager) {
        denyCount += 1
    }
}
