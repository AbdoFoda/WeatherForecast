import XCTest
@testable import WeatherCore

final class MockWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    var shouldFail = false
    
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        if shouldFail { throw WeatherError.invalidResponse }
        return CurrentWeatherResponse(
            coord: Coordinate(lat: lat, lon: lon),
            weather: [],
            main: MainWeather(temp: 20, feelsLike: 20, tempMin: 15, tempMax: 25, pressure: 1013, seaLevel: nil, grndLevel: nil, humidity: 50),
            visibility: nil,
            wind: nil,
            clouds: nil,
            rain: nil,
            snow: nil,
            dt: 0,
            sys: Sys(type: nil, id: nil, country: "DE", sunrise: 0, sunset: 0),
            timezone: 0,
            id: 1,
            name: "Mock City"
        )
    }
    
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        if shouldFail { throw WeatherError.invalidResponse }
        return ForecastResponse(cod: "200", message: nil, cnt: 0, list: [], city: ForecastCity(id: 1, name: "Mock City", coord: Coordinate(lat: lat, lon: lon), country: "DE", population: nil, timezone: 0, sunrise: nil, sunset: nil))
    }
    
    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        if shouldFail { throw WeatherError.invalidResponse }
        return AirPollutionResponse(coord: Coordinate(lat: lat, lon: lon), list: [])
    }
    
    func fetchGeocodingDirect(query: String) async throws -> [GeocodingResult] { [] }
    func fetchGeocodingReverse(lat: Double, lon: Double) async throws -> [GeocodingResult] { [] }
}

@MainActor
final class LocationWeatherViewModelTests: XCTestCase {
    func test_loadWeather_successStateTransition() async {
        let mockService = MockWeatherService()
        let sut = LocationWeatherViewModel(weatherService: mockService)
        
        var states: [String] = []
        let expectation = XCTestExpectation(description: "Wait for loaded state")
        
        sut.onStateChange = { state in
            switch state {
            case .loading:
                states.append("loading")
            case .loaded:
                states.append("loaded")
                expectation.fulfill()
            case .error, .locationPermissionDenied:
                break
            }
        }
        
        await sut.loadWeather(lat: 0, lon: 0)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(states, ["loading", "loaded"])
    }
    
    func test_loadWeather_errorStateTransition() async {
        let mockService = MockWeatherService()
        mockService.shouldFail = true
        let sut = LocationWeatherViewModel(weatherService: mockService)
        
        var states: [String] = []
        let expectation = XCTestExpectation(description: "Wait for error state")
        
        sut.onStateChange = { state in
            switch state {
            case .loading:
                states.append("loading")
            case .error:
                states.append("error")
                expectation.fulfill()
            default:
                break
            }
        }
        
        await sut.loadWeather(lat: 0, lon: 0)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(states, ["loading", "error"])
    }
}
