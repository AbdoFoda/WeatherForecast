@MainActor
public protocol LocationWeatherViewModelProtocol: AnyObject {
    func loadWeather(lat: Double, lon: Double) async
    func refresh(lat: Double, lon: Double) async
    func updateLocationDetails(_ details: LocationDetails)
    func saveTileOrder(_ order: [TileKind])
    func hideTile(_ kind: TileKind)
    func showAllTiles()
    var hasHiddenTiles: Bool { get }
    var onStateChange: ((LocationWeatherViewState) -> Void)? { get set }
}
