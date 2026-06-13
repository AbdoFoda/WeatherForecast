import WeatherCore

@MainActor
final class MockLocationsViewModel: LocationsViewModelProtocol {
    var onStateChange: ((LocationsViewState) -> Void)?
    var state = LocationsViewState.initial
    private(set) var loadCallCount = 0

    func load() {
        loadCallCount += 1
        onStateChange?(state)
    }

    func addLocation(_ location: LocationModel) {}
    func removeLocation(at indexPath: LocationsIndexPath) {}
    func moveLocation(from source: LocationsIndexPath, to destination: LocationsIndexPath) {}
    func selectRow(at indexPath: LocationsIndexPath) -> LocationSelection? { nil }
    func selection(for id: String) -> LocationSelection { .current }

    @discardableResult
    func selectLocation(at index: Int) -> LocationSelection? { nil }
}
