import Foundation

@MainActor
public final class LocationSummariesViewModel: LocationSummariesViewModelProtocol {
    public var onChange: (([String: LocationCardSummary]) -> Void)?
    public private(set) var summaries: [String: LocationCardSummary] = [:]

    private let weatherService: WeatherServiceProtocol
    private var inFlightIDs: Set<String> = []
    private var retryBlockedUntil: [String: Date] = [:]
    private let failureRetryInterval: TimeInterval = 60

    public init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    public func refresh(_ requests: [LocationSummaryRequest]) {
        let now = Date()
        let pending = requests.filter { request in
            guard summaries[request.id] == nil else { return false }
            guard !inFlightIDs.contains(request.id) else { return false }
            let nextRetry = retryBlockedUntil[request.id] ?? .distantPast
            return nextRetry <= now
        }
        guard !pending.isEmpty else { return }
        fetch(pending, forceRetry: false)
    }

    public func reload(_ requests: [LocationSummaryRequest]) {
        guard !requests.isEmpty else { return }
        fetch(requests, forceRetry: true)
    }

    private func fetch(_ requests: [LocationSummaryRequest], forceRetry: Bool) {
        let requested = forceRetry ? requests : requests.filter { !inFlightIDs.contains($0.id) }
        guard !requested.isEmpty else { return }

        if forceRetry {
            requested.forEach { retryBlockedUntil[$0.id] = nil }
        }
        requested.forEach { inFlightIDs.insert($0.id) }

        let weatherService = self.weatherService
        let requestedIDs = requested.map(\.id)
        Task { [weak self] in
            await withTaskGroup(of: (String, LocationCardSummary?).self) { group in
                for request in requested {
                    group.addTask {
                        do {
                            let weather = try await weatherService.fetchCurrentWeather(
                                lat: request.lat,
                                lon: request.lon
                            )
                            return (request.id, WeatherCardSummaryMapper.map(weather: weather))
                        } catch {
                            return (request.id, nil)
                        }
                    }
                }

                for await (id, summary) in group {
                    guard let self else { continue }
                    self.inFlightIDs.remove(id)
                    if let summary {
                        self.retryBlockedUntil[id] = nil
                        self.summaries[id] = summary
                        self.onChange?(self.summaries)
                    } else {
                        self.retryBlockedUntil[id] = Date().addingTimeInterval(self.failureRetryInterval)
                    }
                }
            }
            guard let self else { return }
            requestedIDs.forEach { self.inFlightIDs.remove($0) }
        }
    }
}
