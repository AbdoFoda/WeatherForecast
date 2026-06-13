#if DEBUG
import CoreLocation
import Foundation

@MainActor
final class UITestDeviceLocationManager: DeviceLocationManaging {
    private let observers = NSHashTable<AnyObject>.weakObjects()
    private let coordinate: CLLocationCoordinate2D
    private let sender = LocationManager()

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }

    func addObserver(_ observer: LocationManagerDelegate) {
        observers.add(observer)
    }

    func removeObserver(_ observer: LocationManagerDelegate) {
        observers.remove(observer)
    }

    func requestLocation() {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let current = observers.allObjects.compactMap { $0 as? LocationManagerDelegate }
        let sender = sender
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                current.forEach { $0.locationManager(sender, didUpdateLocation: location) }
            }
        }
    }
}
#endif
