public protocol NetworkReachabilityMonitoring: AnyObject {
    var onConnectionRestored: (@MainActor () -> Void)? { get set }
    func startMonitoring()
    func stopMonitoring()
}
