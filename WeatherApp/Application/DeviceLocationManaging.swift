import Foundation

@MainActor
protocol DeviceLocationManaging: AnyObject {
    func addObserver(_ observer: LocationManagerDelegate)
    func removeObserver(_ observer: LocationManagerDelegate)
    func requestLocation()
}

extension LocationManager: DeviceLocationManaging {}
