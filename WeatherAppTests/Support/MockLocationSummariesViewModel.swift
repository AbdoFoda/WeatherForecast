import WeatherCore

@MainActor
final class MockLocationSummariesViewModel: LocationSummariesViewModelProtocol {
    var onChange: (([String: LocationCardSummary]) -> Void)?
    var summaries: [String: LocationCardSummary] = [:]
    private(set) var refreshedRequests: [[LocationSummaryRequest]] = []
    private(set) var reloadedRequests: [[LocationSummaryRequest]] = []

    func refresh(_ requests: [LocationSummaryRequest]) { refreshedRequests.append(requests) }
    func reload(_ requests: [LocationSummaryRequest]) { reloadedRequests.append(requests) }
}
