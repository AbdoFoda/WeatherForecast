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
    private var locationDetails: LocationDetails?

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

        if let cached = await cachedDisplayFromDisk(lat: lat, lon: lon) {
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

    public func updateLocationDetails(_ details: LocationDetails) {
        guard details != locationDetails else { return }
        locationDetails = details
        republishCached()
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
        Task { await persistToDisk(updated) }
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
        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                async let current = self.weatherService.fetchCurrentWeather(lat: lat, lon: lon)
                async let forecast = self.weatherService.fetchForecast(lat: lat, lon: lon)
                async let air = self.weatherService.fetchAirPollution(lat: lat, lon: lon)

                let (weather, forecastResponse, airPollution) = try await (current, forecast, air)
                guard !Task.isCancelled else { return }

                let display = await DisplayDataMapper.mapOffMainThread(
                    weather: weather,
                    forecast: forecastResponse,
                    airPollution: airPollution,
                    tileOrder: self.tileOrderStore.loadOrder()
                )

                guard !Task.isCancelled,
                      self.lastLatitude == lat,
                      self.lastLongitude == lon else { return }
                self.cachedDisplayData = display
                self.publishLoaded(display, notice: nil)
                await self.persistToDisk(display)
            } catch {
                guard !Task.isCancelled else { return }
                await self.handleFailure(error, lat: lat, lon: lon)
            }
        }
        await currentTask?.value
    }

    private func handleFailure(_ error: Error, lat: Double, lon: Double) async {
        WeatherLogger.log(error)
        let notice: UserNotice = error.isOfflineWeatherError ? .offline : .unavailable

        if let cachedDisplayData {
            publishLoaded(cachedDisplayData, notice: notice)
            return
        }

        if let cached = await cachedDisplayFromDisk(lat: lat, lon: lon) {
            cachedDisplayData = cached
            publishLoaded(cached, notice: notice)
            return
        }

        onStateChange?(.unavailable(notice: notice))
    }

    private func cachedDisplayFromDisk(lat: Double, lon: Double) async -> LocationWeatherDisplayData? {
        guard let entry = await diskCache.load(lat: lat, lon: lon) else { return nil }
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
        let detailed = applyLocationDetails(to: display.withTiles(visibleTiles))
        onStateChange?(.loaded(detailed, notice: notice))
    }

    private func applyLocationDetails(to display: LocationWeatherDisplayData) -> LocationWeatherDisplayData {
        guard let locationDetails, !locationDetails.isEmpty else { return display }
        let altitude = locationDetails.altitudeMeters.map { L10n.Format.altitude(Int($0.rounded())) }
        return display.withLocationDetails(postalCode: locationDetails.postalCode, altitude: altitude)
    }

    private func republishCached() {
        guard let cachedDisplayData else { return }
        publishLoaded(cachedDisplayData, notice: nil)
    }

    private func persistToDisk(_ display: LocationWeatherDisplayData) async {
        guard let lat = lastLatitude, let lon = lastLongitude else { return }
        await diskCache.save(lat: lat, lon: lon, displayData: display)
    }
}
