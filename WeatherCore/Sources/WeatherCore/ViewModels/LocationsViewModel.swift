import Foundation

@MainActor
public final class LocationsViewModel: LocationsViewModelProtocol {
    public var onStateChange: ((LocationsViewState) -> Void)?
    public private(set) var state = LocationsViewState.initial

    private let weatherService: WeatherServiceProtocol
    private let store: SavedLocationsStore
    private var searchTask: Task<Void, Never>?

    public init(weatherService: WeatherServiceProtocol, store: SavedLocationsStore) {
        self.weatherService = weatherService
        self.store = store
    }

    public func load() {
        state = LocationsViewState(
            savedLocations: store.loadLocations(),
            selectedLocationID: store.loadSelectedLocationID(),
            searchQuery: state.searchQuery,
            searchResults: state.searchResults
        )
        publish()
    }

    public func setSearchQuery(_ query: String) async {
        state = LocationsViewState(
            savedLocations: state.savedLocations,
            selectedLocationID: state.selectedLocationID,
            searchQuery: query,
            searchResults: state.searchResults
        )
        publish()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()

        guard trimmed.count >= 2 else {
            if !state.searchResults.isEmpty {
                clearSearchResults()
            }
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                let results = try await weatherService.fetchGeocodingDirect(query: trimmed)
                guard !Task.isCancelled else { return }
                guard state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed else { return }
                applySearchResults(results.map(LocationModel.init(geocodingResult:)))
            } catch {
                guard !Task.isCancelled else { return }
                clearSearchResults()
            }
        }
        await searchTask?.value
    }

    public func addLocation(_ location: LocationModel) {
        if state.savedLocations.contains(where: { $0.id == location.id }) {
            persistSelection(id: location.id, savedLocations: state.savedLocations)
            clearSearchResultsAndQuery()
            return
        }

        var savedLocations = state.savedLocations
        savedLocations.append(location)
        persistSelection(id: location.id, savedLocations: savedLocations)
        clearSearchResultsAndQuery()
    }

    public func addSearchResult(at indexPath: LocationsIndexPath) -> LocationSelection? {
        guard case .search(let location) = state.row(at: indexPath) else { return nil }
        addLocation(location)
        return selection(for: state.selectedLocationID)
    }

    public func removeLocation(at index: Int) {
        guard state.savedLocations.indices.contains(index) else { return }
        var savedLocations = state.savedLocations
        let removed = savedLocations.remove(at: index)
        store.saveLocations(savedLocations)

        if state.selectedLocationID == removed.id {
            persistSelection(id: LocationModel.currentLocationID, savedLocations: savedLocations)
        } else {
            state = LocationsViewState(
                savedLocations: savedLocations,
                selectedLocationID: state.selectedLocationID,
                searchQuery: state.searchQuery,
                searchResults: state.searchResults
            )
            publish()
        }
    }

    public func moveLocation(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              state.savedLocations.indices.contains(sourceIndex) else { return }

        var savedLocations = state.savedLocations
        let item = savedLocations.remove(at: sourceIndex)
        let clampedDestination = max(0, min(destinationIndex, savedLocations.count))
        savedLocations.insert(item, at: clampedDestination)
        store.saveLocations(savedLocations)

        state = LocationsViewState(
            savedLocations: savedLocations,
            selectedLocationID: state.selectedLocationID,
            searchQuery: state.searchQuery,
            searchResults: state.searchResults
        )
        publish()
    }

    public func selectRow(at indexPath: LocationsIndexPath) -> LocationSelection? {
        guard let selection = state.selection(for: indexPath) else { return nil }
        switch selection {
        case .current:
            persistSelection(id: LocationModel.currentLocationID, savedLocations: state.savedLocations)
        case .saved(let location):
            persistSelection(id: location.id, savedLocations: state.savedLocations)
        }
        return selection
    }

    public func selection(for id: String) -> LocationSelection {
        if id == LocationModel.currentLocationID {
            return .current
        }
        guard let location = state.savedLocations.first(where: { $0.id == id }) else {
            return .current
        }
        return .saved(location)
    }

    @discardableResult
    public func selectLocation(at index: Int) -> LocationSelection? {
        let selections = state.selections
        guard selections.indices.contains(index) else { return nil }

        switch selections[index] {
        case .current:
            persistSelection(id: LocationModel.currentLocationID, savedLocations: state.savedLocations)
        case .saved(let location):
            persistSelection(id: location.id, savedLocations: state.savedLocations)
        }
        return selections[index]
    }

    private func persistSelection(id: String, savedLocations: [LocationModel]) {
        store.saveLocations(savedLocations)
        store.saveSelectedLocationID(id)
        state = LocationsViewState(
            savedLocations: savedLocations,
            selectedLocationID: id,
            searchQuery: state.searchQuery,
            searchResults: state.searchResults
        )
        publish()
    }

    private func applySearchResults(_ results: [LocationModel]) {
        state = LocationsViewState(
            savedLocations: state.savedLocations,
            selectedLocationID: state.selectedLocationID,
            searchQuery: state.searchQuery,
            searchResults: results
        )
        publish()
    }

    private func clearSearchResults() {
        guard !state.searchResults.isEmpty else { return }
        state = LocationsViewState(
            savedLocations: state.savedLocations,
            selectedLocationID: state.selectedLocationID,
            searchQuery: state.searchQuery,
            searchResults: []
        )
        publish()
    }

    private func clearSearchResultsAndQuery() {
        state = LocationsViewState(
            savedLocations: state.savedLocations,
            selectedLocationID: state.selectedLocationID,
            searchQuery: "",
            searchResults: []
        )
        publish()
    }

    private func publish() {
        onStateChange?(state)
    }
}
