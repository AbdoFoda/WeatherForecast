import Foundation
import Synchronization

// @unchecked Sendable: the tasks map is only ever mutated inside the Mutex below.
final class SummaryTaskBag: @unchecked Sendable {
    private let tasks = Mutex<[String: Task<Void, Never>]>([:])

    func contains(_ key: String) -> Bool {
        tasks.withLock { $0[key] != nil }
    }

    func insert(_ task: Task<Void, Never>, for key: String) {
        tasks.withLock {
            $0[key]?.cancel()
            $0[key] = task
        }
    }

    func removeValue(forKey key: String) {
        tasks.withLock { _ = $0.removeValue(forKey: key) }
    }

    func cancelAll() {
        tasks.withLock {
            $0.values.forEach { $0.cancel() }
            $0.removeAll()
        }
    }
}
