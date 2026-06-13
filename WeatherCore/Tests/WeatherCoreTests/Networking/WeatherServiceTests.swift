import XCTest
@testable import WeatherCore

final class WeatherServiceTests: XCTestCase {
    private var mockClient: MockHTTPClient!
    private var sut: WeatherService!

    override func setUp() {
        super.setUp()
        mockClient = MockHTTPClient()
        sut = WeatherService(client: mockClient)
    }

    func test_fetchCurrentWeather_decodesCorrectly() async throws {
        let json = """
        {
          "coord": { "lon": 13.4050, "lat": 52.5200 },
          "weather": [
            { "id": 801, "main": "Clouds", "description": "few clouds", "icon": "02d" }
          ],
          "main": {
            "temp": 18.5,
            "feels_like": 17.2,
            "temp_min": 15.0,
            "temp_max": 21.3,
            "pressure": 1013,
            "humidity": 60,
            "sea_level": 1013,
            "grnd_level": 1009
          },
          "visibility": 10000,
          "wind": { "speed": 3.5, "deg": 220, "gust": 5.1 },
          "clouds": { "all": 20 },
          "dt": 1718000000,
          "sys": { "type": 2, "id": 2009729, "country": "DE", "sunrise": 1717982400, "sunset": 1718037600 },
          "timezone": 7200,
          "id": 2950159,
          "name": "Berlin",
          "cod": 200
        }
        """
        mockClient.result = .success(Data(json.utf8))

        let response = try await sut.fetchCurrentWeather(lat: 52.52, lon: 13.405)
        XCTAssertEqual(response.name, "Berlin")
        XCTAssertEqual(response.main.temp, 18.5)
        XCTAssertEqual(response.weather.first?.icon, "02d")
    }
}
