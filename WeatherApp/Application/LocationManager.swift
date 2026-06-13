import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let observers = NSHashTable<AnyObject>.weakObjects()
    private let coreLocationManager = CLLocationManager()
    private var didDeliverLocation = false
    private var isRequestingLocation = false

    override init() {
        super.init()
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func addObserver(_ observer: LocationManagerDelegate) {
        observers.add(observer)
    }

    func removeObserver(_ observer: LocationManagerDelegate) {
        observers.remove(observer)
    }

    private func notifyObservers(_ body: @escaping @MainActor (LocationManager, LocationManagerDelegate) -> Void) {
        let current = observers.allObjects.compactMap { $0 as? LocationManagerDelegate }
        notifyOnMain { [weak self] in
            guard let self else { return }
            current.forEach { body(self, $0) }
        }
    }

    func requestLocation() {
        isRequestingLocation = true
        didDeliverLocation = false
        switch coreLocationManager.authorizationStatus {
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            beginLocationUpdates()
        case .denied, .restricted:
            notifyObservers { manager, observer in
                observer.locationManagerDidDenyPermission(manager)
            }
        @unknown default:
            break
        }
    }

    private func beginLocationUpdates() {
        coreLocationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isRequestingLocation else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            beginLocationUpdates()
        case .denied, .restricted:
            notifyObservers { manager, observer in
                observer.locationManagerDidDenyPermission(manager)
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didDeliverLocation,
              let location = locations.last,
              location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 5_000 else { return }

        didDeliverLocation = true
        notifyObservers { manager, observer in
            observer.locationManager(manager, didUpdateLocation: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        notifyObservers { manager, observer in
            observer.locationManager(manager, didFailWithError: error)
        }
    }

    private func notifyOnMain(_ work: @escaping @MainActor () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            DispatchQueue.main.async {
                MainActor.assumeIsolated(work)
            }
        }
    }
}
