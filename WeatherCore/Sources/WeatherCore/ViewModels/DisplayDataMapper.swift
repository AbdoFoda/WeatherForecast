import Foundation

public struct DisplayDataMapper {
    public static func map(
        weather: CurrentWeatherResponse,
        forecast: ForecastResponse,
        airPollution: AirPollutionResponse
    ) -> LocationWeatherDisplayData {
        let (hourlyItems, minTemp, maxTemp) = HourlyForecastGrouper.process(forecast: forecast)
        
        let tzOffset = TimeInterval(weather.timezone)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "HH:mm"
        
        let sunriseDate = Date(timeIntervalSince1970: weather.sys.sunrise ?? 0).addingTimeInterval(tzOffset)
        let sunsetDate = Date(timeIntervalSince1970: weather.sys.sunset ?? 0).addingTimeInterval(tzOffset)
        
        let aqiValue = airPollution.list.first?.main.aqi ?? 1
        let pm25Value = airPollution.list.first?.components.pm2_5 ?? 0
        let aqiLabels = [1: "Good", 2: "Fair", 3: "Moderate", 4: "Poor", 5: "Very Poor"]
        let aqiString = aqiLabels[aqiValue] ?? "Unknown"
        
        var tiles: [TileDisplayItem] = []
        
        tiles.append(TileDisplayItem(id: "feelsLike", title: "Feels Like", value: "\(Int(round(weather.main.feelsLike)))°", subtitle: nil, tileSize: .standard))
        tiles.append(TileDisplayItem(id: "humidity", title: "Humidity", value: "\(weather.main.humidity)%", subtitle: nil, tileSize: .standard))
        
        let windDeg = weather.wind?.deg ?? 0
        let windSpeed = weather.wind?.speed ?? 0
        let windDir = compassDirection(from: Double(windDeg))
        tiles.append(TileDisplayItem(id: "wind", title: "Wind", value: "\(windSpeed) m/s", subtitle: windDir, tileSize: .standard))
        
        tiles.append(TileDisplayItem(id: "pressure", title: "Pressure", value: "\(weather.main.pressure) hPa", subtitle: nil, tileSize: .standard))
        
        let visibility = (weather.visibility ?? 0) / 1000
        tiles.append(TileDisplayItem(id: "visibility", title: "Visibility", value: "\(visibility) km", subtitle: nil, tileSize: .standard))
        
        tiles.append(TileDisplayItem(id: "sun", title: "Sunrise", value: dateFormatter.string(from: sunriseDate), subtitle: "Sunset: \(dateFormatter.string(from: sunsetDate))", tileSize: .standard))
        
        tiles.append(TileDisplayItem(id: "air", title: "Air Quality", value: aqiString, subtitle: "\(pm25Value) μg/m³", tileSize: .wide))
        tiles.append(TileDisplayItem(id: "clouds", title: "Cloud Cover", value: "\(weather.clouds?.all ?? 0)%", subtitle: nil, tileSize: .standard))
        
        let minT = Int(round(minTemp))
        let maxT = Int(round(maxTemp))
        tiles.append(TileDisplayItem(id: "5day", title: "5-Day Summary", value: "H:\(maxT)° L:\(minT)°", subtitle: nil, tileSize: .wide))
        
        if let firstPop = forecast.list.first?.pop {
            tiles.append(TileDisplayItem(id: "precip", title: "Precipitation", value: "\(Int(firstPop * 100))%", subtitle: "Next 3h", tileSize: .standard))
        }
        
        let iconID = weather.weather.first?.icon ?? "01d"
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconID)@2x.png")!
        
        return LocationWeatherDisplayData(
            cityName: weather.name,
            countryCode: weather.sys.country ?? "",
            currentTemperature: "\(Int(round(weather.main.temp)))°",
            feelsLike: "Feels like \(Int(round(weather.main.feelsLike)))°",
            tempRange: "H:\(Int(round(weather.main.tempMax)))° L:\(Int(round(weather.main.tempMin)))°",
            weatherDescription: (weather.weather.first?.description ?? "").capitalized,
            iconURL: iconURL,
            humidity: "\(weather.main.humidity)%",
            pressure: "\(weather.main.pressure) hPa",
            windSpeed: "\(windSpeed) m/s \(windDir)",
            visibility: "\(visibility) km",
            sunrise: dateFormatter.string(from: sunriseDate),
            sunset: dateFormatter.string(from: sunsetDate),
            aqi: aqiString,
            pm25: "\(pm25Value) μg/m³",
            cloudCoverage: "\(weather.clouds?.all ?? 0)%",
            hourlyItems: hourlyItems,
            tiles: tiles
        )
    }
    
    private static func compassDirection(from degrees: Double) -> String {
        let directions = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
        let index = Int((degrees / 22.5) + 0.5) % 16
        return directions[index]
    }
}
