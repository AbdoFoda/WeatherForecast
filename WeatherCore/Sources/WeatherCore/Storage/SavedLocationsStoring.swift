public protocol SavedLocationsStoring: Sendable {
    func loadLocations() -> [LocationModel]
    func saveLocations(_ locations: [LocationModel])
    func loadSelectedLocationID() -> String
    func saveSelectedLocationID(_ id: String)
}
