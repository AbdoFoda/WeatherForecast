import UIKit
import WeatherCore

final class AppCoordinator {
    private let weatherService: WeatherServiceProtocol

    init() {
        let httpClient = HTTPClient(baseURL: ProxyConfiguration.baseURL)
        weatherService = WeatherService(client: httpClient)
    }
}
