import Foundation

@MainActor
public final class LocationWeatherViewModel: LocationWeatherViewModelProtocol {
    public var onStateChange: ((LocationWeatherViewState) -> Void)?

    private let weatherService: WeatherServiceProtocol
    private var currentTask: Task<Void, Never>?
    private var cachedDisplayData: LocationWeatherDisplayData?

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

                let (weather, forecastResponse, airPollution) = try await (current, forecast, air)
                let display = DisplayDataMapper.map(
                    weather: weather,
                    forecast: forecastResponse,
                    airPollution: airPollution
                )

                guard !Task.isCancelled else { return }
                cachedDisplayData = display
                onStateChange?(.loaded(display, notice: nil))
            } catch {
                guard !Task.isCancelled else { return }
                handleFailure(error)
            }
        }
        await currentTask?.value
    }

    private func handleFailure(_ error: Error) {
        WeatherLogger.log(error)

        if let cachedDisplayData {
            let notice: UserNotice? = error.isOfflineWeatherError ? .offline : nil
            onStateChange?(.loaded(cachedDisplayData, notice: notice))
            return
        }

        let notice: UserNotice? = error.isOfflineWeatherError ? .offline : nil
        onStateChange?(.unavailable(notice: notice))
    }
}
