import UIKit
import WeatherCore

@MainActor
final class AppCoordinator: NSObject {
    private let weatherService: WeatherServiceProtocol
    private let locationsStore = SavedLocationsStore()
    private let tileOrderStore = TileOrderStore()
    private var locationsViewModel: LocationsViewModel?
    private weak var pagerViewController: WeatherPagerViewController?
    private weak var presentedLocationsViewController: LocationsViewController?

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
        let locationsViewModel = LocationsViewModel(weatherService: weatherService, store: locationsStore)
        self.locationsViewModel = locationsViewModel

        locationsViewModel.onStateChange = { [weak self] state in
            self?.pagerViewController?.apply(state)
            self?.presentedLocationsViewController?.render(state)
        }

        let pager = WeatherPagerViewController(
            locationsViewModel: locationsViewModel,
            makeWeatherViewModel: { [weatherService, tileOrderStore] in
                LocationWeatherViewModel(
                    weatherService: weatherService,
                    tileOrderStore: tileOrderStore
                )
            }
        )
        pager.delegate = self
        pagerViewController = pager

        let navigation = UINavigationController(rootViewController: pager)
        navigation.navigationBar.tintColor = .label
        configureTransparentNavigationBar(navigation.navigationBar)

        window.rootViewController = navigation
        window.makeKeyAndVisible()

        locationsViewModel.load()
    }

    private func configureTransparentNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}

extension AppCoordinator: WeatherPagerViewControllerDelegate {
    func weatherPagerViewControllerDidRequestLocationsList(_ controller: WeatherPagerViewController) {
        guard let locationsViewModel else { return }

        let locations = LocationsViewController(viewModel: locationsViewModel)
        locations.delegate = self
        presentedLocationsViewController = locations

        let navigation = UINavigationController(rootViewController: locations)
        navigation.modalPresentationStyle = .formSheet
        controller.present(navigation, animated: true)
    }
}

extension AppCoordinator: LocationsViewControllerDelegate {
    func locationsViewController(_ controller: LocationsViewController, didSelect selection: LocationSelection) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}
