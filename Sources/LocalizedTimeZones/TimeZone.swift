import Foundation
import CoreLocation

extension TimeZone {
    public static var knownTimeZoneLocations: [Location] {
        Location.all
    }
    
    public struct Location: Codable, Identifiable, Equatable, Hashable {
        static let all: [Location] = {
            let url = Bundle.module.url(forResource: "Identifiers", withExtension: "plist")!
            let data = try! Data(contentsOf: url)
            return try! PropertyListDecoder().decode([Location].self, from: data)
        }()
        
        public var id: String { return timeZoneName }
        
        /// -90.0 to 90.0 (in decimal format)
        public let latitude: String
        /// -180.0 to 180.0 (in decimal format)
        public let longitude: String
        /// Unlocalized version of City
        internal let city: String
        /// Localized city name
        public var localizedCity: String {
            Bundle.module.localizedString(forKey: self.city, value: nil, table: "Cities")
        }
        /// Unlocalized version of Country
        internal let country: String
        /// Localized country name
        public var localizedCountry: String {
            let bundle = Bundle.module
            
            return bundle.localizedString(forKey: self.country, value: nil, table: "Countries")
        }
        /// the timeZone name as string
        private let timeZoneName: String
        
        
        public var timeZone: TimeZone! {
            return TimeZone(identifier: self.timeZoneName)
        }
        
        
        //    public var coordinates: CLLocationCoordinate2D {
        //        CLLocationCoordinate2D(latitude: , longitude: <#T##CLLocationDegrees#>)
        //    }
    }
    
}
