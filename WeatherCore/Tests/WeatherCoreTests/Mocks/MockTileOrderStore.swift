import Foundation
@testable import WeatherCore

final class MockTileOrderStore: TileOrderStoring, @unchecked Sendable {
    var order: [TileKind]
    var hidden: Set<TileKind>
    private(set) var savedOrders: [[TileKind]] = []
    private(set) var savedHiddenKinds: [Set<TileKind>] = []

    init(order: [TileKind] = TileKind.allCases, hidden: Set<TileKind> = []) {
        self.order = order
        self.hidden = hidden
    }

    func loadOrder() -> [TileKind] { order }

    func saveOrder(_ order: [TileKind]) {
        self.order = order
        savedOrders.append(order)
    }

    func loadHiddenKinds() -> Set<TileKind> { hidden }

    func saveHiddenKinds(_ kinds: Set<TileKind>) {
        hidden = kinds
        savedHiddenKinds.append(kinds)
    }
}
