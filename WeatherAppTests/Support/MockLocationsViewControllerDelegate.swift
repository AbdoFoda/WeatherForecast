import WeatherCore
@testable import WeatherApp

@MainActor
final class MockLocationsViewControllerDelegate: LocationsViewControllerDelegate {
    private(set) var didSelectSelections: [LocationSelection] = []
    private(set) var didTapAddCount = 0
    private(set) var didRequestRefreshCount = 0

    func locationsViewController(_ controller: LocationsViewController, didSelect selection: LocationSelection) {
        didSelectSelections.append(selection)
    }

    func locationsViewControllerDidTapAdd(_ controller: LocationsViewController) {
        didTapAddCount += 1
    }

    func locationsViewControllerDidRequestRefresh(_ controller: LocationsViewController) {
        didRequestRefreshCount += 1
    }
}
