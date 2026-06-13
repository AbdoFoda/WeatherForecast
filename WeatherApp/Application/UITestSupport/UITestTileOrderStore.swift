#if DEBUG
import Foundation
import Synchronization
import WeatherCore

final class UITestTileOrderStore: TileOrderStoring, @unchecked Sendable {
    private struct State {
        var order: [TileKind]
        var hidden: Set<TileKind>
    }

    private let state: Mutex<State>

    init(order: [TileKind] = TileKind.allCases, hidden: Set<TileKind> = []) {
        state = Mutex(State(order: order, hidden: hidden))
    }

    func loadOrder() -> [TileKind] {
        state.withLock { $0.order }
    }

    func saveOrder(_ order: [TileKind]) {
        state.withLock { $0.order = order }
    }

    func loadHiddenKinds() -> Set<TileKind> {
        state.withLock { $0.hidden }
    }

    func saveHiddenKinds(_ kinds: Set<TileKind>) {
        state.withLock { $0.hidden = kinds }
    }
}
#endif
