#if DEBUG
import Foundation
import WeatherCore

extension AppCoordinator {
    static func uiTesting() -> AppCoordinator {
        let offline = ProcessInfo.processInfo.arguments.contains(UITestLaunchArgument.offline)
        let weatherService = UITestWeatherService(offline: offline)
        let tileOrderStore = UITestTileOrderStore()
        let cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("uitest-weather-\(UUID().uuidString)", isDirectory: true)

        return AppCoordinator(
            weatherService: weatherService,
            locationSearchService: UITestLocationSearchService(),
            locationsStore: UITestSavedLocationsStore(
                locations: UITestWeatherFixtures.seededSavedLocations,
                selectionID: LocationModel.currentLocationID
            ),
            tileOrderStore: tileOrderStore,
            deviceLocationManager: UITestDeviceLocationManager(
                coordinate: UITestWeatherFixtures.deviceCoordinate
            ),
            makeWeatherViewModel: {
                LocationWeatherViewModel(
                    weatherService: weatherService,
                    tileOrderStore: tileOrderStore,
                    diskCache: WeatherDiskCache(directoryURL: cacheDirectory)
                )
            }
        )
    }
}
#endif
