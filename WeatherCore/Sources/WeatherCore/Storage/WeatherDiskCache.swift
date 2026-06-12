import Foundation

public struct WeatherDiskCache: Sendable {
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
    private let fileManager: FileManager

    public init(
        directoryURL: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        if let directoryURL {
            self.directoryURL = directoryURL
        } else {
            let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            self.directoryURL = caches?.appendingPathComponent("weather-display-cache", isDirectory: true)
                ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("weather-display-cache", isDirectory: true)
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
            try data.write(to: fileURL, options: .atomic)
            return true
        } catch {
            return false
        }
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
        if fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return true
        }

        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
}
