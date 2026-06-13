import WeatherCore

@MainActor
protocol LocationsViewControllerDelegate: AnyObject {
    func locationsViewController(_ controller: LocationsViewController, didSelect selection: LocationSelection)
    func locationsViewControllerDidTapAdd(_ controller: LocationsViewController)
    func locationsViewControllerDidRequestRefresh(_ controller: LocationsViewController)
}
