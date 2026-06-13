import Foundation

public actor WeatherService: WeatherServiceProtocol {
    private let client: HTTPClientProtocol
    private let decoder: JSONDecoder
    
    public init(client: HTTPClientProtocol) {
        self.client = client
        self.decoder = JSONDecoder()
    }
    
    public func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        let endpoint = Endpoint.currentWeather(lat: lat, lon: lon)
        return try await fetchAndDecode(endpoint: endpoint, type: CurrentWeatherResponse.self)
    }
    
    public func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        let endpoint = Endpoint.forecast(lat: lat, lon: lon)
        return try await fetchAndDecode(endpoint: endpoint, type: ForecastResponse.self)
    }
    
    public func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        let endpoint = Endpoint.airPollution(lat: lat, lon: lon)
        return try await fetchAndDecode(endpoint: endpoint, type: AirPollutionResponse.self)
    }
    
    private func fetchAndDecode<T: Decodable>(endpoint: Endpoint, type: T.Type) async throws -> T {
        let data = try await client.data(for: endpoint)
        try Task.checkCancellation()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw WeatherError.decodingFailed
        }
    }
}
