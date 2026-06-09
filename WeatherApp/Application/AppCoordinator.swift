import UIKit
import WeatherCore

@MainActor
final class AppCoordinator {
    private let weatherService: WeatherServiceProtocol

    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    static func live(bundle: Bundle = .main) -> AppCoordinator {
        do {
            let baseURL = try ProxyConfigurationLoader.loadBaseURL(bundle: bundle)
            return AppCoordinator(
                weatherService: WeatherService(client: HTTPClient(baseURL: baseURL))
            )
        } catch {
            fatalError("Config.plist must define a valid WeatherProxyBaseURL string.")
        }
    }

    func start(window: UIWindow) {
        let viewModel = LocationWeatherViewModel(weatherService: weatherService)
        let viewController = LocationWeatherViewController(viewModel: viewModel)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
