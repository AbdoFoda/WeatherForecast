import Foundation

public struct HourlyForecastGrouper {
    public static func process(forecast: ForecastResponse) -> (items: [HourlyDisplayItem], minTemp: Double, maxTemp: Double) {
        var minTemp = Double.greatestFiniteMagnitude
        var maxTemp = -Double.greatestFiniteMagnitude
        
        for item in forecast.list {
            minTemp = min(minTemp, item.main.temp)
            maxTemp = max(maxTemp, item.main.temp)
        }
        
        if forecast.list.isEmpty {
            minTemp = 0
            maxTemp = 0
        } else if minTemp == maxTemp {
            minTemp -= 1
            maxTemp += 1
        }
        
        let tzOffset = TimeInterval(forecast.city.timezone)
        var lastDayString: String? = nil
        
        let displayItems: [HourlyDisplayItem] = forecast.list.map { item in
            let date = Date(timeIntervalSince1970: item.dt)
            let localDate = date.addingTimeInterval(tzOffset)
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            dateFormatter.dateFormat = "d MMM"
            let dayString = dateFormatter.string(from: localDate)
            
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: localDate)
            
            let isNewDay = (lastDayString != dayString)
            let dayLabel = isNewDay ? dayString : nil
            lastDayString = dayString
            
            let t = item.main.temp
            let normalisedY = CGFloat(1.0 - ((t - minTemp) / (maxTemp - minTemp)))
            
            let pop = item.pop ?? 0
            let popString = pop > 0 ? "\(Int(pop * 100))%" : nil
            
            let iconID = item.weather.first?.icon ?? "01d"
            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconID)@2x.png")!
            
            return HourlyDisplayItem(
                time: timeString,
                temperature: "\(Int(round(t)))°",
                iconURL: iconURL,
                temperatureDotY: normalisedY,
                isCurrentHour: false,
                dayLabel: dayLabel,
                precipitationChance: popString
            )
        }
        
        return (displayItems, minTemp, maxTemp)
    }
}
