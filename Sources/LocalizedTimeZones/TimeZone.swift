import Foundation
import CoreLocation

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
    
}
