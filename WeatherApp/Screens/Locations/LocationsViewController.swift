import UIKit
import WeatherCore

final class LocationsViewController: UIViewController {
    weak var delegate: LocationsViewControllerDelegate?

    private let viewModel: LocationsViewModelProtocol
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let backgroundGradient = CAGradientLayer()
    private let refreshControl = UIRefreshControl()
    private var state = LocationsViewState.initial
    private var summaries: [String: LocationCardSummary] = [:]

    init(viewModel: LocationsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Locations.title
        navigationController?.navigationBar.prefersLargeTitles = true
        configureBackground()
        configureAddButton()
        configureTableView()
        render(viewModel.state)
    }

    func render(_ state: LocationsViewState) {
        self.state = state
        guard isViewLoaded else { return }
        tableView.reloadData()
    }

    func renderSummaries(_ summaries: [String: LocationCardSummary]) {
        self.summaries = summaries
        guard isViewLoaded else { return }
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    private func configureBackground() {
        view.backgroundColor = .systemGroupedBackground
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
        applyThemeBackground()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applyTheme),
            name: .themeDidChange,
            object: nil
        )
    }

    private func applyThemeBackground() {
        let palette = ThemeManager.shared.palette
        backgroundGradient.colors = [
            palette.listBackgroundTop.cgColor,
            palette.listBackgroundBottom.cgColor
        ]
    }

    @objc private func applyTheme() {
        applyThemeBackground()
        guard isViewLoaded else { return }
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    private func configureAddButton() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
        addButton.accessibilityIdentifier = AccessibilityIdentifier.Locations.addButton
        navigationItem.rightBarButtonItem = addButton

        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "paintpalette"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        settingsButton.accessibilityIdentifier = AccessibilityIdentifier.Locations.settingsButton
        navigationItem.leftBarButtonItem = settingsButton
    }

    @objc private func addTapped() {
        delegate?.locationsViewControllerDidTapAdd(self)
    }

    @objc private func settingsTapped() {
        delegate?.locationsViewControllerDidTapSettings(self)
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.accessibilityIdentifier = AccessibilityIdentifier.Locations.table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Metrics.rowHeight
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.register(LocationCardCell.self, forCellReuseIdentifier: LocationCardCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func handleRefresh() {
        delegate?.locationsViewControllerDidRequestRefresh(self)
    }

    private func cardModel(for row: LocationsRow) -> LocationCardView.Model {
        switch row {
        case .currentLocation(let isSelected):
            let summary = summaries[LocationModel.currentLocationID]
            return LocationCardView.Model(
                title: L10n.Locations.currentLocation,
                subtitle: summary?.localTime ?? "",
                isCurrentLocation: true,
                summary: summary,
                isSelected: isSelected
            )
        case .saved(let location, let isSelected):
            let summary = summaries[location.id]
            return LocationCardView.Model(
                title: location.displayTitle,
                subtitle: summary?.localTime ?? "",
                isCurrentLocation: false,
                summary: summary,
                isSelected: isSelected
            )
        }
    }

    private enum Metrics {
        static let rowHeight: CGFloat = 124
    }
}

extension LocationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        state.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        state.sectionHeader(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationCardCell.reuseIdentifier,
            for: indexPath
        )
        if let cardCell = cell as? LocationCardCell,
           let row = state.row(at: indexPath.locationsIndexPath) {
            cardCell.configure(with: cardModel(for: row))
            cardCell.accessibilityIdentifier = accessibilityIdentifier(for: row)
        }
        return cell
    }

    private func accessibilityIdentifier(for row: LocationsRow) -> String {
        switch row {
        case .currentLocation:
            return AccessibilityIdentifier.Locations.currentCell
        case .saved(let location, _):
            return AccessibilityIdentifier.Locations.cell(id: location.id)
        }
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        guard state.canEditRow(at: indexPath.locationsIndexPath) else { return }
        viewModel.removeLocation(at: indexPath.locationsIndexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        state.canMoveRow(at: indexPath.locationsIndexPath)
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        viewModel.moveLocation(from: sourceIndexPath.locationsIndexPath, to: destinationIndexPath.locationsIndexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        state.canEditRow(at: indexPath.locationsIndexPath)
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        state.canEditRow(at: indexPath.locationsIndexPath) ? .delete : .none
    }
}

extension LocationsViewController: UITableViewDragDelegate {
    func tableView(
        _ tableView: UITableView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard state.canMoveRow(at: indexPath.locationsIndexPath) else { return [] }
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selection = viewModel.selectRow(at: indexPath.locationsIndexPath) else { return }
        delegate?.locationsViewController(self, didSelect: selection)
    }

    func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {
        guard proposedDestinationIndexPath.section == sourceIndexPath.section else {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
}

private extension IndexPath {
    var locationsIndexPath: LocationsIndexPath {
        LocationsIndexPath(section: section, row: row)
    }
}
