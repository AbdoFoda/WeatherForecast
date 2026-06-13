import Foundation

public struct LocationsIndexPath: Equatable, Sendable {
    public let section: Int
    public let row: Int

    public init(section: Int, row: Int) {
        self.section = section
        self.row = row
    }
}
