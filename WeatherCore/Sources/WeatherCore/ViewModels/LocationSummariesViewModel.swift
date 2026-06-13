import Foundation

@MainActor
public final class LocationSummariesViewModel: LocationSummariesViewModelProtocol {
    public var onChange: (([String: LocationCardSummary]) -> Void)?
    public private(set) var summaries: [String: LocationCardSummary] = [:]

    private let weatherService: WeatherServiceProtocol
    private let taskBag = SummaryTaskBag()
    private var retryBlockedUntil: [String: Date] = [:]
    private let failureRetryInterval: TimeInterval = 60

    public init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    deinit {
        taskBag.cancelAll()
    }

    public func refresh(_ requests: [LocationSummaryRequest]) {
        let now = Date()
        let pending = requests.filter { request in
            guard summaries[request.id] == nil else { return false }
            guard !taskBag.contains(request.id) else { return false }
            let nextRetry = retryBlockedUntil[request.id] ?? .distantPast
            return nextRetry <= now
        }
        pending.forEach { startFetch(for: $0) }
    }

    public func reload(_ requests: [LocationSummaryRequest]) {
        for request in requests {
            retryBlockedUntil[request.id] = nil
            startFetch(for: request)
        }
    }

    private func startFetch(for request: LocationSummaryRequest) {
        let weatherService = self.weatherService
        let id = request.id
        let task = Task { [weak self] in
            let summary: LocationCardSummary?
            do {
                let weather = try await weatherService.fetchCurrentWeather(lat: request.lat, lon: request.lon)
                summary = WeatherCardSummaryMapper.map(weather: weather)
            } catch {
                summary = nil
            }

            guard !Task.isCancelled, let self else { return }
            self.complete(id: id, summary: summary)
        }
        taskBag.insert(task, for: id)
    }

    private func complete(id: String, summary: LocationCardSummary?) {
        taskBag.removeValue(forKey: id)
        if let summary {
            retryBlockedUntil[id] = nil
            summaries[id] = summary
            onChange?(summaries)
        } else {
            retryBlockedUntil[id] = Date().addingTimeInterval(failureRetryInterval)
        }
    }
}
