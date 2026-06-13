import Foundation

public enum LocationSelection: Equatable, Sendable {
    case current
    case saved(LocationModel)
}
