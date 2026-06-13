import Foundation
import Network
import Synchronization

// @unchecked Sendable: all mutable state is guarded by the Mutex below.
public final class NetworkReachabilityMonitor: NetworkReachabilityMonitoring, @unchecked Sendable {
    public var onConnectionRestored: (@MainActor () -> Void)?

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    private struct State {
        var isConnected = true
        var hasReceivedInitialPath = false
    }

    private let state = Mutex(State())

    public init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "com.weatherapp.network-reachability")
    }

    deinit {
        monitor.cancel()
    }

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(isSatisfied: path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }

    private func handlePathUpdate(isSatisfied: Bool) {
        let (wasConnected, hadInitialPath) = state.withLock { state -> (Bool, Bool) in
            let previous = (state.isConnected, state.hasReceivedInitialPath)
            state.isConnected = isSatisfied
            state.hasReceivedInitialPath = true
            return previous
        }

        guard hadInitialPath, !wasConnected, isSatisfied else { return }

        let handler = onConnectionRestored
        Task { @MainActor in
            handler?()
        }
    }
}
