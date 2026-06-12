import UIKit
import WeatherCore

@MainActor
protocol WeatherPagerViewControllerDelegate: AnyObject {
    func weatherPagerViewControllerDidRequestLocationsList(_ controller: WeatherPagerViewController)
}

final class WeatherPagerViewController: UIViewController {
    weak var delegate: WeatherPagerViewControllerDelegate?

    private let locationsViewModel: LocationsViewModelProtocol
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

    init(
        locationsViewModel: LocationsViewModelProtocol,
        makeWeatherViewModel: @escaping () -> LocationWeatherViewModelProtocol
    ) {
        self.locationsViewModel = locationsViewModel
        self.makeWeatherViewModel = makeWeatherViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationItem()
        configurePageViewController()
        configurePageControl()
        apply(pendingState ?? locationsViewModel.state)
        pendingState = nil
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

    private func configureNavigationItem() {
        navigationItem.hidesBackButton = true
        let locationsButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(openLocations)
        )
        locationsButton.accessibilityLabel = L10n.Locations.title
        navigationItem.rightBarButtonItem = locationsButton
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
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
    }

    private func page(at index: Int) -> LocationWeatherViewController {
        let selection = selections[index]
        if let existing = pagesByID[selection.pagerID] {
            return existing
        }

        let controller: LocationWeatherViewController
        switch selection {
        case .current:
            controller = LocationWeatherViewController(viewModel: makeWeatherViewModel(), locationSource: .device)
        case .saved(let location):
            controller = LocationWeatherViewController(viewModel: makeWeatherViewModel(), locationSource: .saved(location))
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

    @objc private func openLocations() {
        delegate?.weatherPagerViewControllerDidRequestLocationsList(self)
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
