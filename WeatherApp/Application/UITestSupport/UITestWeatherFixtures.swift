#if DEBUG
import CoreLocation
import Foundation
import WeatherCore

enum UITestWeatherFixtures {
    struct City {
        let id: String
        let name: String
        let country: String
        let lat: Double
        let lon: Double

        var locationModel: LocationModel {
            LocationModel(id: id, name: name, lat: lat, lon: lon, country: country)
        }
    }

    static let current = City(id: "current", name: "Cupertino", country: "US", lat: 37.3349, lon: -122.0090)
    static let berlin = City(id: "berlin", name: "Berlin", country: "DE", lat: 52.5200, lon: 13.4050)
    static let cairo = City(id: "cairo", name: "Cairo", country: "EG", lat: 30.0444, lon: 31.2357)
    static let paris = City(id: "paris", name: "Paris", country: "FR", lat: 48.8566, lon: 2.3522)

    static let seededSavedLocations: [LocationModel] = [berlin.locationModel, cairo.locationModel]
    static let searchCatalog: [City] = [paris]
    static let deviceCoordinate = CLLocationCoordinate2D(latitude: current.lat, longitude: current.lon)

    private static let allCities: [City] = [current, berlin, cairo, paris]

    static func searchResults(matching query: String) -> [LocationModel] {
        let needle = query.lowercased()
        let matches = searchCatalog.filter { $0.name.lowercased().hasPrefix(needle) }
        return (matches.isEmpty ? searchCatalog : matches).map(\.locationModel)
    }

    static func city(lat: Double, lon: Double) -> City {
        allCities.first { abs($0.lat - lat) < 0.01 && abs($0.lon - lon) < 0.01 }
            ?? City(id: "unknown", name: "Test City", country: "", lat: lat, lon: lon)
    }

    static func currentWeatherData(lat: Double, lon: Double) throws -> Data {
        let city = city(lat: lat, lon: lon)
        let payload: [String: Any] = [
            "coord": ["lat": city.lat, "lon": city.lon],
            "weather": [["id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"]],
            "main": mainPayload,
            "visibility": 10000,
            "wind": ["speed": 3.0, "deg": 200],
            "clouds": ["all": 10],
            "dt": referenceTime,
            "sys": ["country": city.country, "sunrise": referenceTime - 21600, "sunset": referenceTime + 21600],
            "timezone": 0,
            "id": 1,
            "name": city.name
        ]
        return try JSONSerialization.data(withJSONObject: payload)
    }

    static func forecastData(lat: Double, lon: Double) throws -> Data {
        let city = city(lat: lat, lon: lon)
        let payload: [String: Any] = [
            "cod": "200",
            "cnt": 1,
            "list": [[
                "dt": referenceTime + 3600,
                "main": mainPayload,
                "weather": [["id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"]],
                "pop": 0.1
            ]],
            "city": [
                "id": 1,
                "name": city.name,
                "coord": ["lat": city.lat, "lon": city.lon],
                "country": city.country,
                "timezone": 0
            ]
        ]
        return try JSONSerialization.data(withJSONObject: payload)
    }

    static func airPollutionData(lat: Double, lon: Double) throws -> Data {
        let city = city(lat: lat, lon: lon)
        let payload: [String: Any] = [
            "coord": ["lat": city.lat, "lon": city.lon],
            "list": [[
                "main": ["aqi": 2],
                "components": [
                    "co": 201.0, "no": 0.0, "no2": 1.2, "o3": 68.0,
                    "so2": 0.5, "pm2_5": 5.0, "pm10": 7.0, "nh3": 0.3
                ],
                "dt": referenceTime
            ]]
        ]
        return try JSONSerialization.data(withJSONObject: payload)
    }

    private static let referenceTime: TimeInterval = 1_700_000_000

    private static let mainPayload: [String: Any] = [
        "temp": 18.0,
        "feels_like": 17.0,
        "temp_min": 14.0,
        "temp_max": 21.0,
        "pressure": 1013,
        "humidity": 55
    ]
}
#endif
