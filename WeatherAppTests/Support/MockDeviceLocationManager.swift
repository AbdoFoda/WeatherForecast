@testable import WeatherApp

@MainActor
final class MockDeviceLocationManager: DeviceLocationManaging {
    private(set) var observers: [LocationManagerDelegate] = []
    private(set) var requestLocationCallCount = 0

    func addObserver(_ observer: LocationManagerDelegate) {
        observers.append(observer)
    }

    func removeObserver(_ observer: LocationManagerDelegate) {
        observers.removeAll { $0 === observer }
    }

    func hasObserver(_ observer: LocationManagerDelegate) -> Bool {
        observers.contains { $0 === observer }
    }

    func requestLocation() {
        requestLocationCallCount += 1
    }
}
