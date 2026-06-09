import UIKit
import WeatherCore

final class AppCoordinator {
    private let weatherService: WeatherServiceProtocol

    init() {
        let httpClient = HTTPClient(baseURL: ProxyConfiguration.baseURL)
        weatherService = WeatherService(client: httpClient)
    }

    func start(window: UIWindow) {
        let viewModel = LocationWeatherViewModel(weatherService: weatherService)
        let viewController = LocationWeatherViewController(viewModel: viewModel)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
