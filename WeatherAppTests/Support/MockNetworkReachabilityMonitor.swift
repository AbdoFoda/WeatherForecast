import WeatherCore
@testable import WeatherApp

final class MockNetworkReachabilityMonitor: NetworkReachabilityMonitoring {
    var onConnectionRestored: (@MainActor () -> Void)?
    private(set) var startCount = 0
    private(set) var stopCount = 0

    func startMonitoring() { startCount += 1 }
    func stopMonitoring() { stopCount += 1 }

    @MainActor
    func simulateConnectionRestored() {
        onConnectionRestored?()
    }
}
