import CoreLocation
import UIKit
import WeatherCore

@MainActor
final class AppCoordinator: NSObject {
    private let weatherService: WeatherServiceProtocol
    private let locationSearchService: LocationSearchProviding
    private let locationsStore = SavedLocationsStore()
    private let tileOrderStore = TileOrderStore()
    private var locationsViewModel: LocationsViewModel?
    private var summariesViewModel: LocationSummariesViewModel?
    private let deviceLocationManager = LocationManager()
    private var deviceCoordinate: (lat: Double, lon: Double)?
    private weak var splitViewController: UISplitViewController?
    private weak var pagerViewController: WeatherPagerViewController?
    private weak var masterViewController: LocationsViewController?
    private weak var addLocationViewController: AddLocationViewController?

    init(
        weatherService: WeatherServiceProtocol,
        locationSearchService: LocationSearchProviding = MapKitLocationSearchService()
    ) {
        self.weatherService = weatherService
        self.locationSearchService = locationSearchService
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
        let locationsViewModel = LocationsViewModel(store: locationsStore)
        self.locationsViewModel = locationsViewModel

        let summariesViewModel = LocationSummariesViewModel(weatherService: weatherService)
        self.summariesViewModel = summariesViewModel

        locationsViewModel.onStateChange = { [weak self] state in
            self?.pagerViewController?.apply(state)
            self?.masterViewController?.render(state)
            self?.refreshSummaries(for: state)
        }
        summariesViewModel.onChange = { [weak self] summaries in
            self?.masterViewController?.renderSummaries(summaries)
        }

        let master = LocationsViewController(viewModel: locationsViewModel)
        master.delegate = self
        masterViewController = master
        let masterNavigation = UINavigationController(rootViewController: master)
        masterNavigation.overrideUserInterfaceStyle = .light

        let pager = WeatherPagerViewController(
            locationsViewModel: locationsViewModel,
            makeWeatherViewModel: { [weatherService, tileOrderStore] in
                LocationWeatherViewModel(
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
        split.setViewController(masterNavigation, for: .primary)
        split.setViewController(detailNavigation, for: .secondary)
        split.preferredDisplayMode = .oneBesideSecondary
        split.preferredSplitBehavior = .tile
        split.delegate = self
        splitViewController = split

        window.rootViewController = split
        window.makeKeyAndVisible()

        locationsViewModel.load()

        deviceLocationManager.delegate = self
        deviceLocationManager.requestLocation()
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

    func locationsViewControllerDidRequestRefresh(_ controller: LocationsViewController) {
        guard let state = locationsViewModel?.state else { return }
        summariesViewModel?.reload(summaryRequests(for: state))
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

    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {}

    func locationManagerDidDenyPermission(_ manager: LocationManager) {}
}
