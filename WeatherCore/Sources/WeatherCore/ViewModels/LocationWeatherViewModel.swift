import Foundation

@MainActor
public final class LocationWeatherViewModel: LocationWeatherViewModelProtocol {
    public var onStateChange: ((LocationWeatherViewState) -> Void)?

    private let weatherService: WeatherServiceProtocol
    private let tileOrderStore: TileOrderStore
    private let diskCache: WeatherDiskCache
    private var currentTask: Task<Void, Never>?
    private var cachedDisplayData: LocationWeatherDisplayData?
    private var lastLatitude: Double?
    private var lastLongitude: Double?

    public init(
        weatherService: WeatherServiceProtocol,
        tileOrderStore: TileOrderStore = TileOrderStore(),
        diskCache: WeatherDiskCache = WeatherDiskCache()
    ) {
        self.weatherService = weatherService
        self.tileOrderStore = tileOrderStore
        self.diskCache = diskCache
    }

    public func loadWeather(lat: Double, lon: Double) async {
        lastLatitude = lat
        lastLongitude = lon

        if let cached = cachedDisplayFromDisk(lat: lat, lon: lon) {
            cachedDisplayData = cached
            publishLoaded(cached, notice: nil)
        } else {
            onStateChange?(.loading)
        }

        await fetchAndPublish(lat: lat, lon: lon)
    }

    public func refresh(lat: Double, lon: Double) async {
        lastLatitude = lat
        lastLongitude = lon
        await fetchAndPublish(lat: lat, lon: lon)
    }

    public func saveTileOrder(_ order: [TileKind]) {
        var fullOrder = order
        for kind in tileOrderStore.loadOrder() where !fullOrder.contains(kind) {
            fullOrder.append(kind)
        }
        tileOrderStore.saveOrder(fullOrder)
        guard let cachedDisplayData else { return }

        let tiles = TileOrderApplier.apply(order: fullOrder, to: cachedDisplayData.tiles)
        let updated = cachedDisplayData.withTiles(tiles)
        self.cachedDisplayData = updated
        persistToDisk(updated)
    }

    public var hasHiddenTiles: Bool {
        !tileOrderStore.loadHiddenKinds().isEmpty
    }

    public func hideTile(_ kind: TileKind) {
        var hidden = tileOrderStore.loadHiddenKinds()
        hidden.insert(kind)
        tileOrderStore.saveHiddenKinds(hidden)
        republishCached()
    }

    public func showAllTiles() {
        tileOrderStore.saveHiddenKinds([])
        republishCached()
    }

    private func fetchAndPublish(lat: Double, lon: Double) async {
        currentTask?.cancel()
        currentTask = Task {
            do {
                async let current = weatherService.fetchCurrentWeather(lat: lat, lon: lon)
                async let forecast = weatherService.fetchForecast(lat: lat, lon: lon)
                async let air = weatherService.fetchAirPollution(lat: lat, lon: lon)

                let (weather, forecastResponse, airPollution) = try await (current, forecast, air)
                let display = DisplayDataMapper.map(
                    weather: weather,
                    forecast: forecastResponse,
                    airPollution: airPollution,
                    tileOrder: tileOrderStore.loadOrder()
                )

                guard !Task.isCancelled else { return }
                cachedDisplayData = display
                persistToDisk(display)
                publishLoaded(display, notice: nil)
            } catch {
                guard !Task.isCancelled else { return }
                handleFailure(error, lat: lat, lon: lon)
            }
        }
        await currentTask?.value
    }

    private func handleFailure(_ error: Error, lat: Double, lon: Double) {
        WeatherLogger.log(error)

        if let cachedDisplayData {
            let notice: UserNotice? = error.isOfflineWeatherError ? .offline : nil
            publishLoaded(cachedDisplayData, notice: notice)
            return
        }

        if let cached = cachedDisplayFromDisk(lat: lat, lon: lon) {
            cachedDisplayData = cached
            let notice: UserNotice? = error.isOfflineWeatherError ? .offline : nil
            publishLoaded(cached, notice: notice)
            return
        }

        let notice: UserNotice? = error.isOfflineWeatherError ? .offline : nil
        onStateChange?(.unavailable(notice: notice))
    }

    private func cachedDisplayFromDisk(lat: Double, lon: Double) -> LocationWeatherDisplayData? {
        guard let entry = diskCache.load(lat: lat, lon: lon) else { return nil }
        return applyTileOrder(to: entry.displayData)
    }

    private func applyTileOrder(to display: LocationWeatherDisplayData) -> LocationWeatherDisplayData {
        let tiles = TileOrderApplier.apply(order: tileOrderStore.loadOrder(), to: display.tiles)
        return display.withTiles(tiles)
    }

    private func publishLoaded(_ display: LocationWeatherDisplayData, notice: UserNotice?) {
        let hidden = tileOrderStore.loadHiddenKinds()
        let visibleTiles = display.tiles.filter { tile in
            guard let kind = TileKind(rawValue: tile.id) else { return true }
            return !hidden.contains(kind)
        }
        onStateChange?(.loaded(display.withTiles(visibleTiles), notice: notice))
    }

    private func republishCached() {
        guard let cachedDisplayData else { return }
        publishLoaded(cachedDisplayData, notice: nil)
    }

    private func persistToDisk(_ display: LocationWeatherDisplayData) {
        guard let lat = lastLatitude, let lon = lastLongitude else { return }
        diskCache.save(lat: lat, lon: lon, displayData: display)
    }
}
