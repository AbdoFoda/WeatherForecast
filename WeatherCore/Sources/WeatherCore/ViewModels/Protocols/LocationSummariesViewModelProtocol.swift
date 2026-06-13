import Foundation

@MainActor
public protocol LocationSummariesViewModelProtocol: AnyObject {
    var onChange: (([String: LocationCardSummary]) -> Void)? { get set }
    var summaries: [String: LocationCardSummary] { get }

    func refresh(_ requests: [LocationSummaryRequest])
    func reload(_ requests: [LocationSummaryRequest])
}
