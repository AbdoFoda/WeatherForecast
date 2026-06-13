import WeatherCore

@MainActor
final class MockAddLocationViewModel: AddLocationViewModelProtocol {
    var onStateChange: ((AddLocationViewState) -> Void)?
    var state = AddLocationViewState.initial
    var results: [LocationModel] = []
    private(set) var queries: [String] = []

    func setQuery(_ query: String) async { queries.append(query) }
    func result(at index: Int) -> LocationModel? {
        results.indices.contains(index) ? results[index] : nil
    }
}
