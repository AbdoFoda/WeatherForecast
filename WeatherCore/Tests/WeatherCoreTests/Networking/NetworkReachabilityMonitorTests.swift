import XCTest
@testable import WeatherCore

final class NetworkReachabilityMonitorTests: XCTestCase {
    func test_onConnectionRestored_concurrentReadWriteIsSafe() {
        let monitor = NetworkReachabilityMonitor()
        monitor.startMonitoring()
        defer { monitor.stopMonitoring() }

        let iterations = 2_000
        let group = DispatchGroup()
        let writers = DispatchQueue(label: "test.writers", attributes: .concurrent)
        let readers = DispatchQueue(label: "test.readers", attributes: .concurrent)

        for _ in 0..<iterations {
            group.enter()
            writers.async {
                monitor.onConnectionRestored = {}
                group.leave()
            }
            group.enter()
            readers.async {
                _ = monitor.onConnectionRestored
                group.leave()
            }
        }

        XCTAssertEqual(group.wait(timeout: .now() + 30), .success)
    }
}
