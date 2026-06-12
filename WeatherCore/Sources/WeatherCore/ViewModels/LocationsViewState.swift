import Foundation

public struct LocationsIndexPath: Equatable, Sendable {
    public let section: Int
    public let row: Int

    public init(section: Int, row: Int) {
        self.section = section
        self.row = row
    }
}

public enum LocationsSection: Sendable {
    case current
    case saved
    case search
}

public enum LocationsRow: Equatable, Sendable {
    case currentLocation(isSelected: Bool)
    case saved(LocationModel, isSelected: Bool)
    case search(LocationModel)
}

public struct LocationsViewState: Equatable, Sendable {
    public let savedLocations: [LocationModel]
    public let selectedLocationID: String
    public let searchQuery: String
    public let searchResults: [LocationModel]

    public static let initial = LocationsViewState(
        savedLocations: [],
        selectedLocationID: LocationModel.currentLocationID,
        searchQuery: "",
        searchResults: []
    )

    public init(
        savedLocations: [LocationModel],
        selectedLocationID: String,
        searchQuery: String,
        searchResults: [LocationModel]
    ) {
        self.savedLocations = savedLocations
        self.selectedLocationID = selectedLocationID
        self.searchQuery = searchQuery
        self.searchResults = searchResults
    }

    public var isSearchActive: Bool {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    public var selections: [LocationSelection] {
        [.current] + savedLocations.map { .saved($0) }
    }

    public var selectedSelectionIndex: Int {
        guard let index = savedLocations.firstIndex(where: { $0.id == selectedLocationID }) else {
            return 0
        }
        return index + 1
    }

    public var sectionCount: Int {
        isSearchActive ? 1 : 2
    }

    public func numberOfRows(in section: Int) -> Int {
        switch sectionKind(for: section) {
        case .current:
            return 1
        case .saved:
            return savedLocations.count
        case .search:
            return searchResults.count
        case .none:
            return 0
        }
    }

    public func sectionHeader(for section: Int) -> String? {
        switch sectionKind(for: section) {
        case .saved:
            return savedLocations.isEmpty ? nil : L10n.Locations.savedHeader
        case .current, .search, .none:
            return nil
        }
    }

    public func row(at indexPath: LocationsIndexPath) -> LocationsRow? {
        switch sectionKind(for: indexPath.section) {
        case .current:
            guard indexPath.row == 0 else { return nil }
            return .currentLocation(isSelected: selectedLocationID == LocationModel.currentLocationID)
        case .saved:
            guard savedLocations.indices.contains(indexPath.row) else { return nil }
            let location = savedLocations[indexPath.row]
            return .saved(location, isSelected: selectedLocationID == location.id)
        case .search:
            guard searchResults.indices.contains(indexPath.row) else { return nil }
            return .search(searchResults[indexPath.row])
        case .none:
            return nil
        }
    }

    public func selection(for indexPath: LocationsIndexPath) -> LocationSelection? {
        switch row(at: indexPath) {
        case .currentLocation:
            return .current
        case .saved(let location, _):
            return .saved(location)
        case .search, .none:
            return nil
        }
    }

    public func canEditRow(at indexPath: LocationsIndexPath) -> Bool {
        sectionKind(for: indexPath.section) == .saved
    }

    public func canMoveRow(at indexPath: LocationsIndexPath) -> Bool {
        sectionKind(for: indexPath.section) == .saved
    }

    private func sectionKind(for section: Int) -> LocationsSection? {
        if isSearchActive {
            return section == 0 ? .search : nil
        }

        switch section {
        case 0:
            return .current
        case 1:
            return .saved
        default:
            return nil
        }
    }
}
