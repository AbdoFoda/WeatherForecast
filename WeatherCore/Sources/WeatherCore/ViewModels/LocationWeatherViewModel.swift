import Foundation

@MainActor
public final class LocationWeatherViewModel: LocationWeatherViewModelProtocol {
    public var onStateChange: ((LocationWeatherViewState) -> Void)?

    private let weatherService: WeatherServiceProtocol
    private let tileOrderStore: any TileOrderStoring
    private let diskCache: WeatherDiskCache
    private var fullDisplayData: LocationWeatherDisplayData?
    private var lastLatitude: Double?
    private var lastLongitude: Double?
    private var locationDetails: LocationDetails?
    private var resolvedPostalCode: String?
    private var barometricAltitudeMeters: Double?
    private var persistTask: Task<Void, Never>?

    public init(
        weatherService: WeatherServiceProtocol,
        tileOrderStore: any TileOrderStoring = TileOrderStore(),
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
            fullDisplayData = cached
            publishLoaded(notice: nil)
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
        let merged = (locationDetails ?? LocationDetails()).merged(with: details)
        guard !merged.isEmpty, merged != locationDetails else { return }
        if let postalCode = merged.postalCode, !postalCode.isEmpty {
            resolvedPostalCode = postalCode
        }
        locationDetails = merged
        republishCached()
    }

    public func saveTileOrder(_ order: [TileKind]) {
        var fullOrder = order
        for kind in tileOrderStore.loadOrder() where !fullOrder.contains(kind) {
            fullOrder.append(kind)
        }
        tileOrderStore.saveOrder(fullOrder)
        guard let fullDisplayData else { return }

        let tiles = TileOrderApplier.apply(order: fullOrder, to: fullDisplayData.tiles)
        let updated = fullDisplayData.withTiles(tiles)
        self.fullDisplayData = updated
        persistTask?.cancel()
        persistTask = Task { [weak self] in await self?.persistToDisk(updated) }
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
        do {
            async let current = weatherService.fetchCurrentWeather(lat: lat, lon: lon)
            async let forecast = weatherService.fetchForecast(lat: lat, lon: lon)
            async let air = weatherService.fetchAirPollution(lat: lat, lon: lon)

            let (weather, forecastResponse, airPollution) = try await (current, forecast, air)
            guard !Task.isCancelled else { return }

            barometricAltitudeMeters = ElevationEstimator.metersAboveSeaLevel(from: weather.main)

            let display = await DisplayDataMapper.mapOffMainThread(
                weather: weather,
                forecast: forecastResponse,
                airPollution: airPollution,
                tileOrder: tileOrderStore.loadOrder()
            )

            guard !Task.isCancelled,
                  lastLatitude == lat,
                  lastLongitude == lon else { return }
            fullDisplayData = display
            publishLoaded(notice: nil)
            await persistToDisk(display)
        } catch {
            guard !Task.isCancelled else { return }
            await handleFailure(error, lat: lat, lon: lon)
        }
    }

    private func handleFailure(_ error: Error, lat: Double, lon: Double) async {
        WeatherLogger.log(error)
        let notice: UserNotice = error.isOfflineWeatherError ? .offline : .unavailable

        if fullDisplayData != nil {
            publishLoaded(notice: notice)
            return
        }

        if let cached = await cachedDisplayFromDisk(lat: lat, lon: lon) {
            fullDisplayData = cached
            publishLoaded(notice: notice)
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

    private func publishLoaded(notice: UserNotice?) {
        guard let fullDisplayData else { return }
        let hidden = tileOrderStore.loadHiddenKinds()
        let visibleTiles = fullDisplayData.tiles.filter { tile in
            guard let kind = TileKind(rawValue: tile.id) else { return true }
            return !hidden.contains(kind)
        }
        let detailed = applyLocationDetails(to: fullDisplayData.withTiles(visibleTiles))
        onStateChange?(.loaded(detailed, notice: notice))
    }

    private func applyLocationDetails(to display: LocationWeatherDisplayData) -> LocationWeatherDisplayData {
        let postalCode = locationDetails?.postalCode ?? resolvedPostalCode
        let altitudeMeters = locationDetails?.altitudeMeters ?? barometricAltitudeMeters
        guard postalCode != nil || altitudeMeters != nil else { return display }

        let altitude = altitudeMeters.map { L10n.Format.altitude(Int($0.rounded())) }
        return display.mergingLocationDetails(postalCode: postalCode, altitude: altitude)
    }

    private func republishCached() {
        guard fullDisplayData != nil else { return }
        publishLoaded(notice: nil)
    }

    private func persistToDisk(_ display: LocationWeatherDisplayData) async {
        guard let lat = lastLatitude, let lon = lastLongitude else { return }
        await diskCache.save(lat: lat, lon: lon, displayData: display)
    }
}
