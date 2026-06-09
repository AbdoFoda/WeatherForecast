import Foundation

@MainActor
public final class LocationWeatherViewModel: LocationWeatherViewModelProtocol {
    public var onStateChange: ((LocationWeatherViewState) -> Void)?
    
    private let weatherService: WeatherServiceProtocol
    private var currentTask: Task<Void, Never>?
    
    public init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }
    
    public func loadWeather(lat: Double, lon: Double) async {
        onStateChange?(.loading)
        await fetchAndPublish(lat: lat, lon: lon)
    }
    
    public func refresh(lat: Double, lon: Double) async {
        await fetchAndPublish(lat: lat, lon: lon)
    }
    
    private func fetchAndPublish(lat: Double, lon: Double) async {
        currentTask?.cancel()
        currentTask = Task {
            do {
                async let current = weatherService.fetchCurrentWeather(lat: lat, lon: lon)
                async let forecast = weatherService.fetchForecast(lat: lat, lon: lon)
                async let air = weatherService.fetchAirPollution(lat: lat, lon: lon)
                
                let (w, f, a) = try await (current, forecast, air)
                let display = DisplayDataMapper.map(weather: w, forecast: f, airPollution: a)
                
                guard !Task.isCancelled else { return }
                onStateChange?(.loaded(display))
            } catch {
                guard !Task.isCancelled else { return }
                onStateChange?(.error(error.localizedDescription))
            }
        }
        await currentTask?.value
    }
}
