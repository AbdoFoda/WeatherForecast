import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationManagerDelegate?
    private let coreLocationManager = CLLocationManager()
    private var didDeliverLocation = false
    private var isRequestingLocation = false

    override init() {
        super.init()
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
            notifyOnMain { [weak self] in
                guard let self else { return }
                self.delegate?.locationManagerDidDenyPermission(self)
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
            notifyOnMain { [weak self] in
                guard let self else { return }
                self.delegate?.locationManagerDidDenyPermission(self)
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
        notifyOnMain { [weak self] in
            guard let self else { return }
            self.delegate?.locationManager(self, didUpdateLocation: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        notifyOnMain { [weak self] in
            guard let self else { return }
            self.delegate?.locationManager(self, didFailWithError: error)
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
