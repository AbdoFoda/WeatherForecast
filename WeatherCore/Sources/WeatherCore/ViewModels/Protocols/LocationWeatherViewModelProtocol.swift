@MainActor
public protocol LocationWeatherViewModelProtocol: AnyObject, Sendable {
    func loadWeather(lat: Double, lon: Double) async
    func refresh(lat: Double, lon: Double) async
    var onStateChange: ((LocationWeatherViewState) -> Void)? { get set }
}
