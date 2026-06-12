import Foundation

@MainActor
public protocol AddLocationViewModelProtocol: AnyObject {
    var onStateChange: ((AddLocationViewState) -> Void)? { get set }
    var state: AddLocationViewState { get }

    func setQuery(_ query: String) async
    func result(at index: Int) -> LocationModel?
}
