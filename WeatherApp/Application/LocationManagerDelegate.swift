import CoreLocation

@MainActor
protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation)
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
    func locationManagerDidDenyPermission(_ manager: LocationManager)
}
