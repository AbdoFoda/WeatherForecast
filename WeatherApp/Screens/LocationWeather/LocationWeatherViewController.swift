import UIKit
import CoreLocation
import WeatherCore

final class LocationWeatherViewController: UIViewController {
    private let viewModel: LocationWeatherViewModelProtocol
    private let locationManager = LocationManager()

    private var currentLatitude: Double?
    private var currentLongitude: Double?

    private let backgroundView = WeatherBackgroundView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let topView = WeatherSummaryView()
    private let graphView = TemperatureGraphCollectionView()
    private let tilesView = TilesContainerView()
    private let attributionLabel = UILabel()
    private let loadingView = LoadingView()
    private let permissionView = LocationPermissionView()
    private let offlineBanner = OfflineBannerView()
    private let refreshControl = UIRefreshControl()

    private var tilesHeightConstraint: NSLayoutConstraint?
    private var graphHeightConstraint: NSLayoutConstraint?
    private var summaryTopConstraint: NSLayoutConstraint?

    init(viewModel: LocationWeatherViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        locationManager.delegate = self
        locationManager.requestLocation()

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

        attributionLabel.text = AppL10n.attribution
        attributionLabel.font = WeatherDesignSystem.Typography.preferred(.caption2)
        attributionLabel.textColor = .tertiaryLabel
        attributionLabel.textAlignment = .center

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl

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

        graphHeightConstraint = graphView.heightAnchor.constraint(
            equalToConstant: WeatherDesignSystem.Layout.graphHeight
        )
        tilesHeightConstraint = tilesView.heightAnchor.constraint(
            equalToConstant: WeatherDesignSystem.Layout.tilesInitialHeight
        )

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
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            graphView.topAnchor.constraint(
                equalTo: topView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.sectionSpacing
            ),
            graphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            graphHeightConstraint!,

            tilesView.topAnchor.constraint(
                equalTo: graphView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.sectionSpacing
            ),
            tilesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tilesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tilesHeightConstraint!,

            attributionLabel.topAnchor.constraint(
                equalTo: tilesView.bottomAnchor,
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
        ])

        summaryTopConstraint = topView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: WeatherDesignSystem.Layout.summaryTopInset
        )
        summaryTopConstraint?.isActive = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        summaryTopConstraint?.constant = view.safeAreaInsets.top + WeatherDesignSystem.Layout.summarySafeAreaExtra
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.loadingView.startAnimating()
                self.permissionView.isHidden = true
                self.setOfflineBannerVisible(false)
                self.backgroundView.configure(with: .neutral)
            case .loaded(let displayData, let notice):
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                self.permissionView.isHidden = true
                self.setContentHidden(false)
                self.topView.configure(with: displayData)
                self.graphView.configure(with: displayData.hourlyItems)
                self.tilesView.configure(with: displayData.tiles)
                self.tilesHeightConstraint?.constant = self.tilesView.intrinsicContentSize.height
                self.setOfflineBannerVisible(notice == .offline)
                self.backgroundView.configure(with: WeatherBackgroundConfiguration(displayData: displayData))
                self.view.setNeedsLayout()
            case .unavailable(let notice):
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                self.permissionView.isHidden = true
                self.setContentHidden(true)
                self.setOfflineBannerVisible(notice == .offline)
                self.backgroundView.configure(with: .neutral)
            case .locationPermissionDenied:
                self.loadingView.stopAnimating()
                self.permissionView.isHidden = false
                self.setOfflineBannerVisible(false)
            }
        }
    }

    private func setContentHidden(_ hidden: Bool) {
        scrollView.isHidden = hidden
    }

    private func setOfflineBannerVisible(_ visible: Bool) {
        offlineBanner.isHidden = !visible
    }

    @objc private func appDidBecomeActive() {
        locationManager.requestLocation()
    }

    @objc private func handleRefresh() {
        guard let lat = currentLatitude, let lon = currentLongitude else {
            locationManager.requestLocation()
            refreshControl.endRefreshing()
            return
        }
        Task {
            await viewModel.refresh(lat: lat, lon: lon)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.graphView.invalidateGraphLayout()
            self?.tilesView.setNeedsLayout()
            self?.tilesView.layoutIfNeeded()
            if let height = self?.tilesView.intrinsicContentSize.height {
                self?.tilesHeightConstraint?.constant = height
            }
        }, completion: nil)
    }
}

extension LocationWeatherViewController: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocation location: CLLocation) {
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
        Task {
            await viewModel.loadWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        }
    }

    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        loadingView.stopAnimating()
        setContentHidden(true)
        setOfflineBannerVisible(false)
        permissionView.configure(message: AppL10n.simulatorLocationHint)
        permissionView.isHidden = false
    }

    func locationManagerDidDenyPermission(_ manager: LocationManager) {
        loadingView.stopAnimating()
        permissionView.isHidden = false
    }
}
