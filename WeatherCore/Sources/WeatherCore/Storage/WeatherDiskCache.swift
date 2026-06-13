import Foundation

public actor WeatherDiskCache {
    public struct Entry: Codable, Sendable {
        public let latitude: Double
        public let longitude: Double
        public let savedAt: Date
        public let displayData: LocationWeatherDisplayData

        public init(
            latitude: Double,
            longitude: Double,
            savedAt: Date,
            displayData: LocationWeatherDisplayData
        ) {
            self.latitude = latitude
            self.longitude = longitude
            self.savedAt = savedAt
            self.displayData = displayData
        }
    }

    private let directoryURL: URL
    private let maxEntryCount: Int

    private var fileManager: FileManager { .default }

    public init(
        directoryURL: URL? = nil,
        maxEntryCount: Int = 50
    ) {
        self.maxEntryCount = max(1, maxEntryCount)
        if let directoryURL {
            self.directoryURL = directoryURL
        } else {
            let folderName = "weather-display-cache"
            let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            let fallback = URL(fileURLWithPath: NSTemporaryDirectory())
            self.directoryURL = caches?.appendingPathComponent(folderName, isDirectory: true)
                ?? fallback.appendingPathComponent(folderName, isDirectory: true)
        }
    }

    public func load(lat: Double, lon: Double) -> Entry? {
        guard let fileURL = fileURL(lat: lat, lon: lon),
              fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let entry = try? JSONDecoder().decode(Entry.self, from: data) else {
            return nil
        }
        return entry
    }

    @discardableResult
    public func save(lat: Double, lon: Double, displayData: LocationWeatherDisplayData) -> Bool {
        guard ensureDirectoryExists() else { return false }

        let entry = Entry(
            latitude: lat,
            longitude: lon,
            savedAt: Date(),
            displayData: displayData
        )

        guard let fileURL = fileURL(lat: lat, lon: lon),
              let data = try? JSONEncoder().encode(entry) else {
            return false
        }

        do {
            try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            evictIfNeeded()
            return true
        } catch {
            return false
        }
    }

    private func evictIfNeeded() {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ), urls.count > maxEntryCount else { return }

        let sorted = urls.sorted { modificationDate(of: $0) < modificationDate(of: $1) }

        for url in sorted.prefix(sorted.count - maxEntryCount) {
            try? fileManager.removeItem(at: url)
        }
    }

    private func modificationDate(of url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
    }

    public func remove(lat: Double, lon: Double) {
        guard let fileURL = fileURL(lat: lat, lon: lon) else { return }
        try? fileManager.removeItem(at: fileURL)
    }

    private func fileURL(lat: Double, lon: Double) -> URL? {
        directoryURL.appendingPathComponent(cacheFileName(lat: lat, lon: lon))
    }

    private func cacheFileName(lat: Double, lon: Double) -> String {
        String(format: "%.4f,%.4f.json", lat, lon)
    }

    private func ensureDirectoryExists() -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory)
            && isDirectory.boolValue

        if !exists {
            guard (try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)) != nil else {
                return false
            }
        }

        applyBackupExclusion()
        return true
    }

    private func applyBackupExclusion() {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableURL = directoryURL
        try? mutableURL.setResourceValues(values)
    }
}
