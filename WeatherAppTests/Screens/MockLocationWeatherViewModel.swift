import WeatherCore
@testable import WeatherApp

@MainActor
final class MockLocationWeatherViewModel: LocationWeatherViewModelProtocol {
    var onStateChange: ((LocationWeatherViewState) -> Void)?
    var hasHiddenTiles = false

    func loadWeather(lat: Double, lon: Double) async {}
    func refresh(lat: Double, lon: Double) async {}
    func updateLocationDetails(_ details: LocationDetails) {}
    func saveTileOrder(_ order: [TileKind]) {}
    func hideTile(_ kind: TileKind) {}
    func showAllTiles() {}

    func emit(_ state: LocationWeatherViewState) {
        onStateChange?(state)
    }
}
