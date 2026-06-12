import UIKit
import WeatherCore

@MainActor
protocol AddLocationViewControllerDelegate: AnyObject {
    func addLocationViewController(_ controller: AddLocationViewController, didSelect location: LocationModel)
    func addLocationViewControllerDidCancel(_ controller: AddLocationViewController)
}

final class AddLocationViewController: UIViewController {
    weak var delegate: AddLocationViewControllerDelegate?

    private let viewModel: AddLocationViewModelProtocol
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private var state = AddLocationViewState.initial

    init(viewModel: AddLocationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Locations.addLocationTitle
        view.backgroundColor = .systemGroupedBackground
        configureCancelButton()
        configureSearch()
        configureTableView()
        bindViewModel()
    }

    private func configureCancelButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    @objc private func cancelTapped() {
        delegate?.addLocationViewControllerDidCancel(self)
    }

    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.placeholder = L10n.Locations.searchPlaceholder
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.state = state
            self?.tableView.reloadData()
        }
    }
}

extension AddLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.resultCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if let location = state.result(at: indexPath.row) {
            content.text = location.displayTitle
            content.image = UIImage(systemName: "plus.circle")
        }
        cell.contentConfiguration = content
        return cell
    }
}

extension AddLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let location = viewModel.result(at: indexPath.row) else { return }
        delegate?.addLocationViewController(self, didSelect: location)
    }
}

extension AddLocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        Task { await viewModel.setQuery(query) }
    }
}
