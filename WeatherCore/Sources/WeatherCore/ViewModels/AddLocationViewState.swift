import Foundation

public struct AddLocationViewState: Equatable, Sendable {
    public let query: String
    public let results: [LocationModel]
    public let isSearching: Bool
    public let searchFailed: Bool

    public static let initial = AddLocationViewState(
        query: "",
        results: [],
        isSearching: false,
        searchFailed: false
    )

    public init(query: String, results: [LocationModel], isSearching: Bool, searchFailed: Bool = false) {
        self.query = query
        self.results = results
        self.isSearching = isSearching
        self.searchFailed = searchFailed
    }

    public var resultCount: Int { results.count }

    public func result(at index: Int) -> LocationModel? {
        guard results.indices.contains(index) else { return nil }
        return results[index]
    }
}
