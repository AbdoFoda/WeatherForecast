import Foundation

public struct LocationsViewState: Equatable, Sendable {
    public let savedLocations: [LocationModel]
    public let selectedLocationID: String

    public static let initial = LocationsViewState(
        savedLocations: [],
        selectedLocationID: LocationModel.currentLocationID
    )

    public init(
        savedLocations: [LocationModel],
        selectedLocationID: String
    ) {
        self.savedLocations = savedLocations
        self.selectedLocationID = selectedLocationID
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

    public var sectionCount: Int { 2 }

    public func numberOfRows(in section: Int) -> Int {
        switch sectionKind(for: section) {
        case .current:
            return 1
        case .saved:
            return savedLocations.count
        case .none:
            return 0
        }
    }

    public func sectionHeader(for section: Int) -> String? {
        switch sectionKind(for: section) {
        case .saved:
            return savedLocations.isEmpty ? nil : L10n.Locations.savedHeader
        case .current, .none:
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
        case .none:
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
