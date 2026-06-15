import CoreLocation
import UIKit
import WeatherCore

@MainActor
final class AppCoordinator: NSObject {
    private let weatherService: WeatherServiceProtocol
    private let locationSearchService: LocationSearchProviding
    private let locationsStore: any SavedLocationsStoring
    private let tileOrderStore: any TileOrderStoring
    private let makeLocationsViewModel: @MainActor (any SavedLocationsStoring) -> LocationsViewModelProtocol
    private let makeSummariesViewModel: @MainActor (WeatherServiceProtocol) -> LocationSummariesViewModelProtocol
    private let makeWeatherViewModelOverride: (@MainActor () -> LocationWeatherViewModelProtocol)?
    private var locationsViewModel: LocationsViewModelProtocol?
    private var summariesViewModel: LocationSummariesViewModelProtocol?
    private let deviceLocationManager: DeviceLocationManaging
    private var deviceCoordinate: (lat: Double, lon: Double)?
    private weak var splitViewController: UISplitViewController?
    private weak var pagerViewController: WeatherPagerViewController?
    private weak var primaryViewController: LocationsViewController?
    private weak var addLocationViewController: AddLocationViewController?

    init(
        weatherService: WeatherServiceProtocol,
        locationSearchService: LocationSearchProviding = MapKitLocationSearchService(),
        locationsStore: any SavedLocationsStoring = SavedLocationsStore(),
        tileOrderStore: any TileOrderStoring = TileOrderStore(),
        deviceLocationManager: DeviceLocationManaging = LocationManager(),
        makeLocationsViewModel: @escaping @MainActor (any SavedLocationsStoring) -> LocationsViewModelProtocol = {
            LocationsViewModel(store: $0)
        },
        makeSummariesViewModel: @escaping @MainActor (WeatherServiceProtocol) -> LocationSummariesViewModelProtocol = {
            LocationSummariesViewModel(weatherService: $0)
        },
        makeWeatherViewModel: (@MainActor () -> LocationWeatherViewModelProtocol)? = nil
    ) {
        self.weatherService = weatherService
        self.locationSearchService = locationSearchService
        self.locationsStore = locationsStore
        self.tileOrderStore = tileOrderStore
        self.deviceLocationManager = deviceLocationManager
        self.makeLocationsViewModel = makeLocationsViewModel
        self.makeSummariesViewModel = makeSummariesViewModel
        self.makeWeatherViewModelOverride = makeWeatherViewModel
    }

    private static let fallbackBaseURL =
        URL(string: "https://weather-proxy.invalid") ?? URL(fileURLWithPath: "/dev/null")

    static func live(bundle: Bundle = .main) -> AppCoordinator {
        do {
            let baseURL = try ProxyConfigurationLoader.loadBaseURL(bundle: bundle)
            return AppCoordinator(
                weatherService: WeatherService(client: HTTPClient(baseURL: baseURL))
            )
        } catch {
            WeatherLogger.log(error)
            assertionFailure("Config.plist must define a valid WeatherProxyBaseURL string.")
            return AppCoordinator(
                weatherService: WeatherService(client: HTTPClient(baseURL: fallbackBaseURL))
            )
        }
    }

    func start(window: UIWindow) {
        let locationsViewModel = makeLocationsViewModel(locationsStore)
        self.locationsViewModel = locationsViewModel

        let summariesViewModel = makeSummariesViewModel(weatherService)
        self.summariesViewModel = summariesViewModel

        bindViewModels(locationsViewModel: locationsViewModel, summariesViewModel: summariesViewModel)

        let split = makeSplitViewController(locationsViewModel: locationsViewModel)
        splitViewController = split
        window.rootViewController = split
        window.makeKeyAndVisible()

        locationsViewModel.load()

        deviceLocationManager.addObserver(self)
        deviceLocationManager.requestLocation()
    }

    private func bindViewModels(
        locationsViewModel: LocationsViewModelProtocol,
        summariesViewModel: LocationSummariesViewModelProtocol
    ) {
        locationsViewModel.onStateChange = { [weak self] state in
            self?.pagerViewController?.apply(state)
            self?.primaryViewController?.render(state)
            self?.refreshSummaries(for: state)
        }
        summariesViewModel.onChange = { [weak self] summaries in
            self?.primaryViewController?.renderSummaries(summaries)
        }
    }

    private func makeSplitViewController(locationsViewModel: LocationsViewModelProtocol) -> UISplitViewController {
        let primary = LocationsViewController(viewModel: locationsViewModel)
        primary.delegate = self
        primaryViewController = primary
        let primaryNavigation = UINavigationController(rootViewController: primary)
        primaryNavigation.overrideUserInterfaceStyle = .light

        let pager = WeatherPagerViewController(
            locationsViewModel: locationsViewModel,
            deviceLocationManager: deviceLocationManager,
            makeWeatherViewModel: { [weatherService, tileOrderStore, makeWeatherViewModelOverride] in
                if let makeWeatherViewModelOverride {
                    return makeWeatherViewModelOverride()
                }
                return LocationWeatherViewModel(
                    weatherService: weatherService,
                    tileOrderStore: tileOrderStore
                )
            }
        )
        pagerViewController = pager
        let detailNavigation = UINavigationController(rootViewController: pager)
        detailNavigation.navigationBar.tintColor = .label
        configureTransparentNavigationBar(detailNavigation.navigationBar)

        let split = UISplitViewController(style: .doubleColumn)
        split.setViewController(primaryNavigation, for: .primary)
        split.setViewController(detailNavigation, for: .secondary)
        split.preferredDisplayMode = .oneBesideSecondary
        split.preferredSplitBehavior = .tile
        split.delegate = self
        return split
    }

    private func configureTransparentNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

    private func schedulePageContainerRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.pagerViewController?.refreshPageContainerLayout()
        }
    }

    private func showDetail() {
        splitViewController?.show(.secondary)
        schedulePageContainerRefresh()
    }

    private func summaryRequests(for state: LocationsViewState) -> [LocationSummaryRequest] {
        var requests = state.savedLocations.map {
            LocationSummaryRequest(id: $0.id, lat: $0.lat, lon: $0.lon)
        }
        if let deviceCoordinate {
            requests.insert(
                LocationSummaryRequest(
                    id: LocationModel.currentLocationID,
                    lat: deviceCoordinate.lat,
                    lon: deviceCoordinate.lon
                ),
                at: 0
            )
        }
        return requests
    }

    private func refreshSummaries(for state: LocationsViewState) {
        summariesViewModel?.refresh(summaryRequests(for: state))
    }
}

extension AppCoordinator: LocationsViewControllerDelegate {
    func locationsViewController(_ controller: LocationsViewController, didSelect selection: LocationSelection) {
        showDetail()
    }

    func locationsViewControllerDidTapAdd(_ controller: LocationsViewController) {
        let viewModel = AddLocationViewModel(searchProvider: locationSearchService)
        let addController = AddLocationViewController(viewModel: viewModel)
        addController.delegate = self
        addLocationViewController = addController

        let navigation = UINavigationController(rootViewController: addController)
        navigation.modalPresentationStyle = .formSheet
        controller.present(navigation, animated: true)
    }

    func locationsViewControllerDidTapSettings(_ controller: LocationsViewController) {
        let settingsController = ThemeSettingsViewController()
        settingsController.delegate = self

        let navigation = UINavigationController(rootViewController: settingsController)
        navigation.modalPresentationStyle = .pageSheet
        if let sheet = navigation.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        controller.present(navigation, animated: true)
    }

    func locationsViewControllerDidRequestRefresh(_ controller: LocationsViewController) {
        guard let state = locationsViewModel?.state else { return }
        summariesViewModel?.reload(summaryRequests(for: state))
    }
}

extension AppCoordinator: ThemeSettingsViewControllerDelegate {
    func themeSettingsViewControllerDidFinish(_ controller: ThemeSettingsViewController) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}

extension AppCoordinator: AddLocationViewControllerDelegate {
    func addLocationViewController(_ controller: AddLocationViewController, didSelect location: LocationModel) {
        locationsViewModel?.addLocation(location)
        controller.presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.showDetail()
        }
        addLocationViewController = nil
    }

    func addLocationViewControllerDidCancel(_ controller: AddLocationViewController) {
        controller.presentingViewController?.dismiss(animated: true)
        addLocationViewController = nil
    }
}

extension AppCoordinator: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        .secondary
    }
}

extension AppCoordinator: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        deviceCoordinate = (location.coordinate.latitude, location.coordinate.longitude)
        guard let state = locationsViewModel?.state else { return }
        refreshSummaries(for: state)
    }

    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        WeatherLogger.log(error)
        deviceCoordinate = nil
    }

    func locationManagerDidDenyPermission(_ manager: LocationManager) {
        WeatherLogger.log("Device location permission denied; current-location summary unavailable.")
        deviceCoordinate = nil
    }
}
