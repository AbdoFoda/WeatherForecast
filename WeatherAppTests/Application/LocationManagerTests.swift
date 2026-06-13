import XCTest
import CoreLocation
@testable import WeatherApp

@MainActor
final class LocationManagerTests: XCTestCase {
    func test_didUpdateLocations_forwardsToAllObservers() {
        let sut = LocationManager()
        let first = MockLocationManagerDelegate()
        let second = MockLocationManagerDelegate()
        sut.addObserver(first)
        sut.addObserver(second)

        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.40),
            altitude: 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: Date()
        )
        sut.locationManager(CLLocationManager(), didUpdateLocations: [location])

        XCTAssertEqual(first.updatedLocations.count, 1)
        XCTAssertEqual(second.updatedLocations.count, 1)
        XCTAssertEqual(first.updatedLocations.first?.coordinate.latitude ?? 0, 52.52, accuracy: 0.0001)
    }

    func test_didFailWithError_forwardsToObserver() {
        let sut = LocationManager()
        let delegate = MockLocationManagerDelegate()
        sut.addObserver(delegate)

        sut.locationManager(CLLocationManager(), didFailWithError: NSError(domain: "test", code: 1))

        XCTAssertEqual(delegate.errors.count, 1)
    }

    func test_removedObserver_stopsReceivingUpdates() {
        let sut = LocationManager()
        let delegate = MockLocationManagerDelegate()
        sut.addObserver(delegate)
        sut.removeObserver(delegate)

        let location = CLLocation(latitude: 1, longitude: 2)
        sut.locationManager(CLLocationManager(), didUpdateLocations: [location])

        XCTAssertEqual(delegate.updatedLocations.count, 0)
    }
}
