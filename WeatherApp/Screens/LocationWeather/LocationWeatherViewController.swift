import UIKit
import CoreLocation
import MapKit
import WeatherCore

final class LocationWeatherViewController: UIViewController {
    var onTileDragStateChanged: ((Bool) -> Void)?

    let viewModel: LocationWeatherViewModelProtocol
    let locationSource: LocationWeatherSource
    let deviceLocationManager: DeviceLocationManaging?
    let reachabilityMonitor: NetworkReachabilityMonitoring
    let geocoder = CLGeocoder()

    var currentLatitude: Double?
    var currentLongitude: Double?

    let backgroundView = WeatherBackgroundView()
    let scrollView = VerticalOnlyScrollView()
    let contentView = UIView()
    let topView = WeatherSummaryView()
    let graphView = TemperatureGraphCollectionView()
    let tilesView = TilesContainerView()
    let attributionLabel = UILabel()
    let loadingView = LoadingView()
    let permissionView = LocationPermissionView()
    let offlineBanner = OfflineBannerView()
    let refreshControl = UIRefreshControl()
    let refreshSpinner = UIActivityIndicatorView(style: .medium)

    var tilesHeightConstraint: NSLayoutConstraint?
    var graphHeightConstraint: NSLayoutConstraint?
    var summaryTopConstraint: NSLayoutConstraint?
    var lastTilesLayoutBounds: CGSize = .zero
    var weatherTask: Task<Void, Never>?
    var locationDetailsTask: Task<Void, Never>?
    var reconnectRetryTask: Task<Void, Never>?
    var isShowingNotice = false
    var isShowingBackOnlineNotice = false
    var backOnlineDismissWorkItem: DispatchWorkItem?

    let reconnectRetryInterval: TimeInterval = 5

    init(
        viewModel: LocationWeatherViewModelProtocol,
        locationSource: LocationWeatherSource = .device,
        deviceLocationManager: DeviceLocationManaging? = nil,
        reachabilityMonitor: NetworkReachabilityMonitoring = NetworkReachabilityMonitor()
    ) {
        self.viewModel = viewModel
        self.locationSource = locationSource
        self.deviceLocationManager = deviceLocationManager
        self.reachabilityMonitor = reachabilityMonitor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        reachabilityMonitor.stopMonitoring()
        backOnlineDismissWorkItem?.cancel()
        weatherTask?.cancel()
        locationDetailsTask?.cancel()
        reconnectRetryTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        if case .device = locationSource {
            deviceLocationManager?.addObserver(self)
        }
        loadInitialWeather()
        startReachabilityMonitoring()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTilesLayoutForAvailableSpace()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshLayoutAfterExternalTransition()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        summaryTopConstraint?.constant = view.safeAreaInsets.top + WeatherDesignSystem.Layout.summarySafeAreaExtra
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
        lastTilesLayoutBounds = .zero
        view.setNeedsLayout()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.loadingView.startAnimating()
                self.permissionView.setVisible(false)
                self.setOfflineBannerVisible(false)
                self.backgroundView.configure(with: .neutral)
            case .loaded(let displayData, let notice):
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                self.refreshSpinner.stopAnimating()
                self.permissionView.setVisible(false)
                self.setContentHidden(false)
                self.topView.configure(with: displayData)
                self.graphView.configure(with: displayData.hourlyItems)
                let tileSetChanged = self.tilesView.currentTileIDs != Set(displayData.tiles.map(\.id))
                self.tilesView.configure(with: displayData.tiles)
                if tileSetChanged {
                    self.updateTilesHeight()
                }
                self.apply(notice: notice)
                self.backgroundView.configure(with: WeatherBackgroundConfiguration(displayData: displayData))
                self.view.setNeedsLayout()
            case .unavailable(let notice):
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                self.refreshSpinner.stopAnimating()
                self.permissionView.setVisible(false)
                self.setContentHidden(true)
                self.apply(notice: notice)
                self.backgroundView.configure(with: .neutral)
            case .locationPermissionDenied:
                self.loadingView.stopAnimating()
                self.permissionView.setVisible(true)
                self.setOfflineBannerVisible(false)
            }
        }
    }

    func setContentHidden(_ hidden: Bool) {
        scrollView.isHidden = hidden
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.graphView.invalidateGraphLayout()
            self?.updateTilesLayoutForAvailableSpace()
        }, completion: nil)
    }
}

extension LocationWeatherViewController: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
        resolveDeviceLocationDetails(for: location)
        weatherTask?.cancel()
        weatherTask = Task { [weak self] in
            await self?.viewModel.loadWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        }
    }

    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        loadingView.stopAnimating()
        refreshSpinner.stopAnimating()
        refreshControl.endRefreshing()
        setContentHidden(true)
        setOfflineBannerVisible(false)
        permissionView.configure(message: AppL10n.simulatorLocationHint)
        permissionView.setVisible(true)
    }

    func locationManagerDidDenyPermission(_ manager: LocationManager) {
        loadingView.stopAnimating()
        permissionView.configure(message: AppL10n.locationPermissionMessage)
        permissionView.setVisible(true)
    }
}
