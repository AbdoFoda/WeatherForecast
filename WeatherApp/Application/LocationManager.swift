import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation)
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
    func locationManagerDidDenyPermission(_ manager: LocationManager)
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationManagerDelegate?
    private let coreLocationManager = CLLocationManager()
    private var didDeliverLocation = false

    override init() {
        super.init()
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        didDeliverLocation = false
        switch coreLocationManager.authorizationStatus {
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            beginLocationUpdates()
        case .denied, .restricted:
            delegate?.locationManagerDidDenyPermission(self)
        @unknown default:
            break
        }
    }

    private func beginLocationUpdates() {
        coreLocationManager.stopUpdatingLocation()
        coreLocationManager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            beginLocationUpdates()
        case .denied, .restricted:
            coreLocationManager.stopUpdatingLocation()
            delegate?.locationManagerDidDenyPermission(self)
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
        coreLocationManager.stopUpdatingLocation()
        delegate?.locationManager(self, didUpdateLocation: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coreLocationManager.stopUpdatingLocation()
        delegate?.locationManager(self, didFailWithError: error)
    }
}
