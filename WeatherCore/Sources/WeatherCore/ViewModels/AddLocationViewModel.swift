import Foundation

@MainActor
public final class AddLocationViewModel: AddLocationViewModelProtocol {
    public var onStateChange: ((AddLocationViewState) -> Void)?
    public private(set) var state = AddLocationViewState.initial

    private let searchProvider: LocationSearchProviding
    private var searchTask: Task<Void, Never>?

    private let minimumQueryLength = 2
    private let debounceNanoseconds: UInt64 = 300_000_000

    public init(searchProvider: LocationSearchProviding) {
        self.searchProvider = searchProvider
    }

    public func setQuery(_ query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()

        guard trimmed.count >= minimumQueryLength else {
            update(query: query, results: [], isSearching: false)
            return
        }

        update(query: query, results: state.results, isSearching: true)

        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: self.debounceNanoseconds)
                guard !Task.isCancelled else { return }
                let results = try await self.searchProvider.search(query: trimmed)
                guard !Task.isCancelled else { return }
                guard self.state.query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed else { return }
                self.update(query: self.state.query, results: results, isSearching: false)
            } catch {
                guard !Task.isCancelled else { return }
                self.update(query: self.state.query, results: [], isSearching: false, searchFailed: true)
            }
        }
        await searchTask?.value
    }

    public func result(at index: Int) -> LocationModel? {
        state.result(at: index)
    }

    private func update(query: String, results: [LocationModel], isSearching: Bool, searchFailed: Bool = false) {
        state = AddLocationViewState(query: query, results: results, isSearching: isSearching, searchFailed: searchFailed)
        onStateChange?(state)
    }
}
