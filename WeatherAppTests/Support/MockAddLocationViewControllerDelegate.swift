import WeatherCore
@testable import WeatherApp

@MainActor
final class MockAddLocationViewControllerDelegate: AddLocationViewControllerDelegate {
    private(set) var didSelectLocations: [LocationModel] = []
    private(set) var didCancelCount = 0

    func addLocationViewController(_ controller: AddLocationViewController, didSelect location: LocationModel) {
        didSelectLocations.append(location)
    }

    func addLocationViewControllerDidCancel(_ controller: AddLocationViewController) {
        didCancelCount += 1
    }
}
