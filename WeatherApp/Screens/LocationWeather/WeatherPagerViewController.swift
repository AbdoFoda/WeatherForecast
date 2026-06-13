import UIKit
import WeatherCore

final class WeatherPagerViewController: UIViewController {
    private let locationsViewModel: LocationsViewModelProtocol
    private let deviceLocationManager: DeviceLocationManaging
    private let makeWeatherViewModel: () -> LocationWeatherViewModelProtocol

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let pageControl = UIPageControl()

    private var selections: [LocationSelection] = []
    private var pagesByID: [String: LocationWeatherViewController] = [:]
    private var currentIndex = 0
    private var pendingState: LocationsViewState?
    private var isRefreshingPageContainer = false

    init(
        locationsViewModel: LocationsViewModelProtocol,
        deviceLocationManager: DeviceLocationManaging,
        makeWeatherViewModel: @escaping () -> LocationWeatherViewModelProtocol
    ) {
        self.locationsViewModel = locationsViewModel
        self.deviceLocationManager = deviceLocationManager
        self.makeWeatherViewModel = makeWeatherViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configurePageViewController()
        configurePageControl()
        apply(pendingState ?? locationsViewModel.state)
        pendingState = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isRefreshingPageContainer, pageContainerNeedsRefresh else { return }
        refreshPageContainerLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshPageContainerLayout()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        refreshPageContainerLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.refreshPageContainerLayout()
        })
    }

    func apply(_ state: LocationsViewState) {
        guard isViewLoaded else {
            pendingState = state
            return
        }

        let newSelections = state.selections
        let newIDs = newSelections.map(\.pagerID)
        let oldIDs = selections.map(\.pagerID)
        let selectedIndex = state.selectedSelectionIndex

        if newIDs != oldIDs {
            selections = newSelections
            pagesByID = pagesByID.filter { newIDs.contains($0.key) }
            showPage(at: selectedIndex, animated: false)
        } else if selectedIndex != currentIndex {
            showPage(at: selectedIndex, animated: true)
        }
        updatePageControl()
    }

    private func configurePageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }

    private func configurePageControl() {
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        pageControl.backgroundStyle = .minimal
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func updatePageControl() {
        pageControl.numberOfPages = selections.count
        pageControl.currentPage = currentIndex
        if !selections.isEmpty {
            pageControl.setIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
        }
    }

    private func showPage(at index: Int, animated: Bool) {
        guard selections.indices.contains(index) else { return }
        let direction: UIPageViewController.NavigationDirection = index >= currentIndex ? .forward : .reverse
        currentIndex = index
        pageViewController.setViewControllers(
            [page(at: index)],
            direction: direction,
            animated: animated
        )
        updatePageControl()
        updateActivePageAnimations()
    }

    private func updateActivePageAnimations() {
        guard selections.indices.contains(currentIndex) else { return }
        let activeID = selections[currentIndex].pagerID
        for (id, controller) in pagesByID {
            controller.setBackgroundAnimationsActive(id == activeID)
        }
    }

    private func page(at index: Int) -> LocationWeatherViewController {
        let selection = selections[index]
        if let existing = pagesByID[selection.pagerID] {
            return existing
        }

        let controller: LocationWeatherViewController
        switch selection {
        case .current:
            controller = LocationWeatherViewController(
                viewModel: makeWeatherViewModel(),
                locationSource: .device,
                deviceLocationManager: deviceLocationManager
            )
        case .saved(let location):
            controller = LocationWeatherViewController(
                viewModel: makeWeatherViewModel(),
                locationSource: .saved(location)
            )
        }
        controller.onTileDragStateChanged = { [weak self] isDragging in
            self?.setPagingEnabled(!isDragging)
        }
        pagesByID[selection.pagerID] = controller
        return controller
    }

    private func pageIndex(of controller: UIViewController) -> Int? {
        guard let weatherController = controller as? LocationWeatherViewController else { return nil }
        return selections.firstIndex { pagesByID[$0.pagerID] === weatherController }
    }

    private func setPagingEnabled(_ enabled: Bool) {
        for case let scrollView as UIScrollView in pageViewController.view.subviews {
            scrollView.isScrollEnabled = enabled
        }
    }

    func refreshPageContainerLayout() {
        guard !isRefreshingPageContainer else { return }
        isRefreshingPageContainer = true
        defer { isRefreshingPageContainer = false }

        if let pageScrollView = pageViewController.view.subviews.first(where: { $0 is UIScrollView }) {
            pageScrollView.frame = pageViewController.view.bounds
            pageScrollView.layoutIfNeeded()
        }

        guard selections.indices.contains(currentIndex) else { return }
        let controller = page(at: currentIndex)
        pageViewController.setViewControllers(
            [controller],
            direction: .forward,
            animated: false
        )
        relayoutAllWeatherPages()
        updateActivePageAnimations()
    }

    private var pageContainerNeedsRefresh: Bool {
        let containerBounds = pageViewController.view.bounds
        guard containerBounds.width > 0 else { return false }

        if let pageScrollView = pageViewController.view.subviews.first(where: { $0 is UIScrollView }),
           abs(pageScrollView.bounds.width - containerBounds.width) > 1 {
            return true
        }

        guard let weatherPage = pageViewController.viewControllers?.first else { return false }
        return abs(weatherPage.view.bounds.width - containerBounds.width) > 1
    }

    func relayoutAllWeatherPages() {
        pagesByID.values.forEach { $0.refreshLayoutAfterExternalTransition() }
    }

    @objc private func pageControlChanged() {
        let target = pageControl.currentPage
        guard target != currentIndex else { return }
        showPage(at: target, animated: true)
        locationsViewModel.selectLocation(at: target)
    }
}

extension WeatherPagerViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pageIndex(of: viewController), index > 0 else { return nil }
        return page(at: index - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pageIndex(of: viewController), index < selections.count - 1 else { return nil }
        return page(at: index + 1)
    }
}

extension WeatherPagerViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visible = pageViewController.viewControllers?.first,
              let index = pageIndex(of: visible),
              index != currentIndex else { return }

        currentIndex = index
        updatePageControl()
        updateActivePageAnimations()
        locationsViewModel.selectLocation(at: index)
    }
}

private extension LocationSelection {
    var pagerID: String {
        switch self {
        case .current:
            return LocationModel.currentLocationID
        case .saved(let location):
            return location.id
        }
    }
}
