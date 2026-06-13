import UIKit
import CoreLocation
import WeatherCore

final class LocationWeatherViewController: UIViewController {
    var onTileDragStateChanged: ((Bool) -> Void)?

    private let viewModel: LocationWeatherViewModelProtocol
    private let locationSource: LocationWeatherSource
    private let locationManager = LocationManager()
    private let geocoder = CLGeocoder()

    private var currentLatitude: Double?
    private var currentLongitude: Double?

    private let backgroundView = WeatherBackgroundView()
    private let scrollView = VerticalOnlyScrollView()
    private let contentView = UIView()
    private let topView = WeatherSummaryView()
    private let graphView = TemperatureGraphCollectionView()
    private let tilesView = TilesContainerView()
    private let attributionLabel = UILabel()
    private let loadingView = LoadingView()
    private let permissionView = LocationPermissionView()
    private let offlineBanner = OfflineBannerView()
    private let refreshControl = UIRefreshControl()
    private let refreshSpinner = UIActivityIndicatorView(style: .medium)

    private var tilesHeightConstraint: NSLayoutConstraint?
    private var graphHeightConstraint: NSLayoutConstraint?
    private var summaryTopConstraint: NSLayoutConstraint?
    private var lastTilesLayoutBounds: CGSize = .zero
    private var weatherTask: Task<Void, Never>?

    init(
        viewModel: LocationWeatherViewModelProtocol,
        locationSource: LocationWeatherSource = .device
    ) {
        self.viewModel = viewModel
        self.locationSource = locationSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        weatherTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        locationManager.delegate = self
        loadInitialWeather()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func setupUI() {
        view.backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        graphView.translatesAutoresizingMaskIntoConstraints = false
        tilesView.translatesAutoresizingMaskIntoConstraints = false
        attributionLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        permissionView.translatesAutoresizingMaskIntoConstraints = false
        offlineBanner.translatesAutoresizingMaskIntoConstraints = false
        permissionView.isHidden = true
        offlineBanner.isHidden = true
        loadingView.stopAnimating()

        attributionLabel.text = AppL10n.attribution
        attributionLabel.font = WeatherDesignSystem.Typography.preferred(.caption2)
        attributionLabel.textColor = .tertiaryLabel
        attributionLabel.textAlignment = .center

        scrollView.delaysContentTouches = false
        configureRefreshControl()
        configureTileCallbacks()

        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(graphView)
        contentView.addSubview(tilesView)
        contentView.addSubview(attributionLabel)
        view.addSubview(loadingView)
        view.addSubview(permissionView)
        view.addSubview(offlineBanner)
        view.addSubview(refreshSpinner)

        let graphHeightConstraint = graphView.heightAnchor.constraint(
            equalToConstant: WeatherDesignSystem.Layout.graphHeight
        )
        self.graphHeightConstraint = graphHeightConstraint
        let tilesHeightConstraint = tilesView.heightAnchor.constraint(
            equalToConstant: WeatherDesignSystem.Layout.tilesInitialHeight
        )
        self.tilesHeightConstraint = tilesHeightConstraint

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(
                greaterThanOrEqualTo: scrollView.heightAnchor,
                constant: 1
            ),

            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            graphView.topAnchor.constraint(
                equalTo: topView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.sectionSpacing
            ),
            graphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            graphHeightConstraint,

            tilesView.topAnchor.constraint(
                equalTo: graphView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.sectionSpacing
            ),
            tilesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tilesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tilesHeightConstraint,

            attributionLabel.topAnchor.constraint(
                greaterThanOrEqualTo: tilesView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.attributionBottomInset
            ),
            attributionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            attributionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            attributionLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -WeatherDesignSystem.Layout.attributionBottomInset
            ),

            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            permissionView.topAnchor.constraint(equalTo: view.topAnchor),
            permissionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            permissionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            permissionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            offlineBanner.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            offlineBanner.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            offlineBanner.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -WeatherDesignSystem.Layout.offlineBannerBottomInset
            ),

            refreshSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshSpinner.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: WeatherDesignSystem.Layout.summarySafeAreaExtra
            ),
        ])

        summaryTopConstraint = topView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: WeatherDesignSystem.Layout.summaryTopInset
        )
        summaryTopConstraint?.isActive = true
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        refreshControl.tintColor = .clear
        refreshSpinner.translatesAutoresizingMaskIntoConstraints = false
        refreshSpinner.hidesWhenStopped = true
        refreshSpinner.color = .white
        refreshSpinner.layer.shadowColor = UIColor.black.cgColor
        refreshSpinner.layer.shadowOpacity = 0.25
        refreshSpinner.layer.shadowRadius = 3
        refreshSpinner.layer.shadowOffset = .zero
    }

    private func configureTileCallbacks() {
        tilesView.onOrderChanged = { [weak self] order in
            self?.viewModel.saveTileOrder(order)
        }
        tilesView.onDragStateChanged = { [weak self] isDragging in
            guard let self else { return }
            self.scrollView.panGestureRecognizer.isEnabled = !isDragging
            self.onTileDragStateChanged?(isDragging)
        }
        tilesView.onTileMenuRequested = { [weak self] kind, sourceView in
            self?.presentTileMenu(for: kind, from: sourceView)
        }
    }

    private func updateTilesHeight() {
        tilesView.setNeedsLayout()
        tilesView.layoutIfNeeded()
        tilesHeightConstraint?.constant = tilesView.intrinsicContentSize.height
    }

    func setBackgroundAnimationsActive(_ active: Bool) {
        if active {
            backgroundView.resumeAnimations()
        } else {
            backgroundView.pauseAnimations()
        }
    }

    func refreshLayoutAfterExternalTransition() {
        lastTilesLayoutBounds = .zero
        graphView.invalidateGraphLayout()
        tilesView.prepareForContainerSizeChange()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func updateTilesLayoutForAvailableSpace() {
        contentView.layoutIfNeeded()

        let visibleHeight = scrollView.bounds.height
        let visibleWidth = scrollView.bounds.width
        let boundsSize = CGSize(width: visibleWidth, height: visibleHeight)

        let fixedHeight =
            (summaryTopConstraint?.constant ?? 0)
            + topView.bounds.height
            + WeatherDesignSystem.Layout.sectionSpacing
            + (graphHeightConstraint?.constant ?? WeatherDesignSystem.Layout.graphHeight)
            + WeatherDesignSystem.Layout.sectionSpacing
            + attributionLabel.bounds.height
            + WeatherDesignSystem.Layout.attributionBottomInset * 2

        let availableForTiles = max(0, visibleHeight - fixedHeight)
        let boundsChanged =
            abs(boundsSize.width - lastTilesLayoutBounds.width) > 0.5
            || abs(boundsSize.height - lastTilesLayoutBounds.height) > 0.5
        let targetHeightChanged = abs(tilesView.layoutTargetHeight - availableForTiles) > 0.5
        guard boundsChanged || targetHeightChanged else { return }

        lastTilesLayoutBounds = boundsSize
        tilesView.layoutTargetHeight = availableForTiles
        if boundsChanged {
            tilesView.prepareForContainerSizeChange()
        }
        tilesView.invalidateIntrinsicContentSize()
        updateTilesHeight()
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

    private func setContentHidden(_ hidden: Bool) {
        scrollView.isHidden = hidden
    }

    private func apply(notice: UserNotice?) {
        switch notice {
        case .offline:
            offlineBanner.setMessage(L10n.Notice.offline)
            offlineBanner.isHidden = false
        case .unavailable:
            offlineBanner.setMessage(L10n.Notice.unavailable)
            offlineBanner.isHidden = false
        case nil:
            offlineBanner.isHidden = true
        }
    }

    private func setOfflineBannerVisible(_ visible: Bool) {
        offlineBanner.isHidden = !visible
    }

    private func loadInitialWeather() {
        switch locationSource {
        case .device:
            locationManager.requestLocation()
        case .saved(let location):
            currentLatitude = location.lat
            currentLongitude = location.lon
            viewModel.updateLocationDetails(
                LocationDetails(postalCode: location.postalCode, altitudeMeters: location.altitude)
            )
            weatherTask?.cancel()
            weatherTask = Task { [weak self] in
                await self?.viewModel.loadWeather(lat: location.lat, lon: location.lon)
            }
        }
    }

    private func resolveDeviceLocationDetails(for location: CLLocation) {
        let altitude = location.verticalAccuracy > 0 ? location.altitude : nil
        viewModel.updateLocationDetails(LocationDetails(postalCode: nil, altitudeMeters: altitude))

        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let postalCode = placemarks?.first?.postalCode
            let details = LocationDetails(postalCode: postalCode, altitudeMeters: altitude)
            Task { @MainActor [weak self] in
                self?.viewModel.updateLocationDetails(details)
            }
        }
    }

    @objc private func appDidBecomeActive() {
        guard case .device = locationSource else { return }
        locationManager.requestLocation()
    }

    private func presentTileMenu(for kind: TileKind, from sourceView: UIView) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: L10n.Tiles.remove, style: .destructive) { [weak self] _ in
            self?.viewModel.hideTile(kind)
        })
        if viewModel.hasHiddenTiles {
            sheet.addAction(UIAlertAction(title: L10n.Tiles.showAll, style: .default) { [weak self] _ in
                self?.viewModel.showAllTiles()
            })
        }
        sheet.addAction(UIAlertAction(title: AppL10n.cancel, style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        present(sheet, animated: true)
    }

    @objc private func handleRefresh() {
        guard let lat = currentLatitude, let lon = currentLongitude else {
            locationManager.requestLocation()
            refreshControl.endRefreshing()
            return
        }
        refreshSpinner.startAnimating()
        weatherTask?.cancel()
        weatherTask = Task { [weak self] in
            await self?.viewModel.refresh(lat: lat, lon: lon)
        }
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
