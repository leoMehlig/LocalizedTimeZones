import Foundation
import CoreLocation
import MapKit

extension TimeZone {
    public static var knownTimeZoneLocations: [Location] {
        Location.all
    }
    
    public static var locationDictionary: [String: Location] {
        Location.dictionary
    }
    
    public var location: Location? {
        Location.dictionary[self.identifier]
    }
    
    public var symbol: String {
        switch self.identifier.components(separatedBy: "/").first {
        case "America"?, "Pacific"?, "US"?, "Canada"?, "Brazil"?:
            return "globe.americas.fill"
        case "Europe"?, "Africa"?, "GMT"?, "UTC"?, "Atlantic"?:
            return "globe.europe.africa.fill"
        case "Asia"?, "Indian"?:
            return "globe.central.south.asia.fill"
        case "Australia"?:
            return "globe.asia.australia.fill"
        default:
            return "globe"
        }
    }
    
    public struct Location: Codable, Identifiable, Equatable, Hashable {
        static let all: [Location] = {
            let url = Bundle.module.url(forResource: "Identifiers", withExtension: "plist")!
            let data = try! Data(contentsOf: url)
            return try! PropertyListDecoder().decode([Location].self, from: data)
        }()
        
        static let dictionary: [String: Location] = {
            Dictionary(Location.all.map({ ($0.identifier, $0) }), uniquingKeysWith: { element, _ in element })
        }()
        
        public var id: String { return "\(self.city), \(self.country) (\(identifier))" }
        
        /// -90.0 to 90.0 (in decimal format)
        let latitude: Double
        
        /// -180.0 to 180.0 (in decimal format)
        let longitude: Double
        
        /// Unlocalized version of City
        public let city: String
        
        /// Localized city name
        public var localizedCity: String {
            Bundle.module.localizedString(forKey: self.city, value: nil, table: "Cities")
        }
        /// Unlocalized version of Country
        public let country: String
        
        /// Localized country name
        public var localizedCountry: String {
            Bundle.module.localizedString(forKey: self.country, value: nil, table: "Countries")
        }
        /// the timeZone name as string
        public let identifier: String
        
        
        public var timeZone: TimeZone! {
            return TimeZone(identifier: identifier)
        }
        
        
        public var coordinates: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    @available(iOS 16, *)
    public static func loadMissing() async {
        let missing = TimeZone.knownTimeZoneIdentifiers.filter({ TimeZone(identifier: $0)?.location == nil })
        var locations = [Location]()
        var cityLocalizations: [String: [String: String]] = [:]
        var countryLocalizations: [String: [String: String]] = [:]
        let locals = ["ar",
                      "ca",
                      "cs",
                      "da",
                      "de",
                      "el",
                      "en",
                      "es-419",
                      "es",
                      "fi",
                      "fr",
                      "he",
                      "hi",
                      "hr",
                      "hu",
                      "id",
                      "it",
                      "ja",
                      "ko",
                      "ms",
                      "nb",
                      "nl",
                      "pl",
                      "pt-PT",
                      "pt",
                      "ro",
                      "ru",
                      "sk",
                      "sv",
                      "th",
                      "tr",
                      "uk",
                      "vi",
                      "zh-Hans",
                      "zh-Hant"]
        for (index, identifier) in missing.enumerated() {
                let comps = identifier.replacingOccurrences(of: "_", with: " ").split(separator: "/")
                var city: String
                if identifier == "America/Bahia_Banderas" {
                    city = "Bahía de Banderas"
                } else if comps.count > 2 {
                    city = "\(comps[2]), \(comps[1])"
                } else {
                    city = String(comps.last!)
                }
                let timeZone = TimeZone(identifier: identifier)!
                let geocoder = CLGeocoder()
                print(city, identifier)
                let places = try? await geocoder.geocodeAddressString(city)
                var placemark = places?.first(where: {
                    $0.timeZone?.abbreviation() == timeZone.abbreviation()
                })
                if placemark == nil {
                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = city
                    let search = MKLocalSearch(request: request)
                    let response = try? await search.start()
                    placemark = response?.mapItems.first(where: {
                        $0.timeZone?.abbreviation() == timeZone.abbreviation()
                    })?.placemark
                }
                guard let placemark,
                      let coordinates = placemark.location,
                      let city = placemark.locality ?? placemark.name,
                      let country = placemark.country ?? placemark.name else {
                    print("Failed for", identifier)
                    continue
                }
                let location = Location(latitude: coordinates.coordinate.latitude,
                                        longitude: coordinates.coordinate.longitude,
                                        city: city,
                                        country: country,
                                        identifier: identifier)
                locations.append(location)
                for local in locals {
                    if let localizedPlacemark = try! await geocoder.reverseGeocodeLocation(coordinates,
                                                                                           preferredLocale: .init(identifier: local)).first {
                        cityLocalizations[local, default: [:]][city] = localizedPlacemark.locality
                        countryLocalizations[local, default: [:]][country] = localizedPlacemark.country
                    } else {
                        print("Failed for", identifier)
                    }
                }
            await MainActor.run { [locations, cityLocalizations, countryLocalizations] in
                let allLocations = self.knownTimeZoneLocations + locations
                let data = try! PropertyListEncoder().encode(allLocations)
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Identifiers.plist")
                try! data.write(to: path)
                for local in locals {
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        .appending(component: "Resources")
                        .appending(component: local + ".lproj")
                    try! FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
                    let bundle = Bundle.bundle(for: local)
                    let cities = Set(allLocations.map(\.city)).sorted().map { city in
                        (city, cityLocalizations[local]?[city] ?? bundle.localizedString(forKey: city, value: nil, table: "Cities"))
                    }.map {
                        "\"\($0.0)\" = \"\($0.1)\";"
                    }
                        .joined(separator: "\n")
                        .data(using: .utf8)!
                    try! cities.write(to: path.appending(component: "Cities.strings"))
                    let countries = Set(allLocations.map(\.country)).sorted().map { country in
                        (country, countryLocalizations[local]?[country] ?? bundle.localizedString(forKey: country, value: nil, table: "Countries"))
                    }.map {
                        "\"\($0.0)\" = \"\($0.1)\";"
                    }
                        .joined(separator: "\n")
                        .data(using: .utf8)!
                    try! countries.write(to: path.appending(component: "Countries.strings"))
                    
                }
            }
            
            print("Completed \(index+1)/\(missing.count)")
            try! await Task.sleep(for: .seconds(60))
        }
    
        
    }
}

extension Bundle {
    static func bundle(for local: String) -> Bundle {
        let path = Bundle.module.path(forResource: local, ofType: "lproj")
        return Bundle(path: path!)!
    }
}
