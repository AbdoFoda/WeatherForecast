public enum LocationsRow: Equatable, Sendable {
    case currentLocation(isSelected: Bool)
    case saved(LocationModel, isSelected: Bool)
}
