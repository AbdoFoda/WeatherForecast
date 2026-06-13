import WeatherCore

@MainActor
protocol AddLocationViewControllerDelegate: AnyObject {
    func addLocationViewController(_ controller: AddLocationViewController, didSelect location: LocationModel)
    func addLocationViewControllerDidCancel(_ controller: AddLocationViewController)
}
