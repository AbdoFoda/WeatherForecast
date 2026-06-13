enum AccessibilityIdentifier {
    enum Locations {
        static let table = "locations.table"
        static let addButton = "locations.addButton"
        static let currentCell = "locations.cell.current"
        static func cell(id: String) -> String { "locations.cell.\(id)" }
    }

    enum AddLocation {
        static let searchField = "addLocation.searchField"
        static func result(id: String) -> String { "addLocation.result.\(id)" }
    }

    enum Summary {
        static let city = "summary.city"
        static let temperature = "summary.temperature"
    }

    enum Detail {
        static let scroll = "detail.scroll"
    }

    enum Banner {
        static let offline = "offlineBanner"
    }
}
