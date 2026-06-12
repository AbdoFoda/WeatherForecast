import Foundation

@MainActor
public protocol LocationsViewModelProtocol: AnyObject {
    var onStateChange: ((LocationsViewState) -> Void)? { get set }
    var state: LocationsViewState { get }

    func load()
    func addLocation(_ location: LocationModel)
    func removeLocation(at index: Int)
    func moveLocation(from sourceIndex: Int, to destinationIndex: Int)
    func selectRow(at indexPath: LocationsIndexPath) -> LocationSelection?
    func selection(for id: String) -> LocationSelection

    @discardableResult
    func selectLocation(at index: Int) -> LocationSelection?
}
