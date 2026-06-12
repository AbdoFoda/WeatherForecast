import Foundation

@MainActor
public protocol LocationsViewModelProtocol: AnyObject, Sendable {
    var onStateChange: ((LocationsViewState) -> Void)? { get set }
    var state: LocationsViewState { get }

    func load()
    func setSearchQuery(_ query: String) async
    func addLocation(_ location: LocationModel)
    func addSearchResult(at indexPath: LocationsIndexPath) -> LocationSelection?
    func removeLocation(at index: Int)
    func moveLocation(from sourceIndex: Int, to destinationIndex: Int)
    func selectRow(at indexPath: LocationsIndexPath) -> LocationSelection?
    func selection(for id: String) -> LocationSelection

    @discardableResult
    func selectLocation(at index: Int) -> LocationSelection?
}
