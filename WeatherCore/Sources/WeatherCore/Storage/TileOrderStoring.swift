public protocol TileOrderStoring: Sendable {
    func loadOrder() -> [TileKind]
    func saveOrder(_ order: [TileKind])
    func loadHiddenKinds() -> Set<TileKind>
    func saveHiddenKinds(_ kinds: Set<TileKind>)
}
