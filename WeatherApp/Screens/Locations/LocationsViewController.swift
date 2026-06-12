import UIKit
import WeatherCore

@MainActor
protocol LocationsViewControllerDelegate: AnyObject {
    func locationsViewController(_ controller: LocationsViewController, didSelect selection: LocationSelection)
}

final class LocationsViewController: UIViewController {
    weak var delegate: LocationsViewControllerDelegate?

    private let viewModel: LocationsViewModelProtocol
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private var state = LocationsViewState.initial

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
        view.backgroundColor = .systemGroupedBackground
        configureCloseButton()
        configureSearch()
        configureTableView()
        render(viewModel.state)
    }

    func render(_ state: LocationsViewState) {
        self.state = state
        guard isViewLoaded else { return }
        tableView.reloadData()
    }

    private func configureCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.Locations.searchPlaceholder
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        switch state.row(at: indexPath.locationsIndexPath) {
        case .currentLocation(let isSelected):
            content.text = L10n.Locations.currentLocation
            content.image = UIImage(systemName: "location.fill")
            cell.accessoryType = isSelected ? .checkmark : .none
        case .saved(let location, let isSelected):
            content.text = location.displayTitle
            content.image = nil
            cell.accessoryType = isSelected ? .checkmark : .none
        case .search(let location):
            content.text = location.displayTitle
            content.image = UIImage(systemName: "plus.circle")
            cell.accessoryType = .none
        case .none:
            break
        }

        cell.contentConfiguration = content
        cell.selectionStyle = .default
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        guard state.canEditRow(at: indexPath.locationsIndexPath) else { return }
        viewModel.removeLocation(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        state.canMoveRow(at: indexPath.locationsIndexPath)
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        viewModel.moveLocation(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        state.canEditRow(at: indexPath.locationsIndexPath)
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

        if let selection = viewModel.addSearchResult(at: indexPath.locationsIndexPath) {
            delegate?.locationsViewController(self, didSelect: selection)
            collapseSearchUI()
            return
        }

        guard let selection = viewModel.selectRow(at: indexPath.locationsIndexPath) else { return }
        delegate?.locationsViewController(self, didSelect: selection)
        collapseSearchUI()
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

    private func collapseSearchUI() {
        guard searchController.isActive else { return }
        searchController.isActive = false
        searchController.searchBar.text = nil
    }
}

private extension IndexPath {
    var locationsIndexPath: LocationsIndexPath {
        LocationsIndexPath(section: section, row: row)
    }
}

extension LocationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        Task { await viewModel.setSearchQuery(query) }
    }
}
