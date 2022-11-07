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
    
    public struct Location: Codable, Identifiable, Equatable, Hashable {
        static let all: [Location] = {
            let url = Bundle.module.url(forResource: "Identifiers", withExtension: "plist")!
            let data = try! Data(contentsOf: url)
            return try! PropertyListDecoder().decode([Location].self, from: data)
        }()
        
        static let dictionary: [String: Location] = {
            Dictionary(uniqueKeysWithValues: Location.all.map({ ($0.identifier, $0) }))
        }()
        
        public var id: String { return "\(self.city), \(self.country) (\(identifier))" }
        
        /// -90.0 to 90.0 (in decimal format)
        let latitude: Double
        
        /// -180.0 to 180.0 (in decimal format)
        let longitude: Double
        
        /// Unlocalized version of City
        let city: String
        
        /// Localized city name
        public var localizedCity: String {
            Bundle.module.localizedString(forKey: self.city, value: nil, table: "Cities")
        }
        /// Unlocalized version of Country
        let country: String
        
        /// Localized country name
        public var localizedCountry: String {
            Bundle.module.localizedString(forKey: self.country, value: nil, table: "Countries")
        }
        /// the timeZone name as string
        let identifier: String
        
        
        public var timeZone: TimeZone! {
            return TimeZone(identifier: identifier)
        }
        
        
        public var coordinates: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
}
