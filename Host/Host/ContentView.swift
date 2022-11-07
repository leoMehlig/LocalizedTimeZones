//
//  ContentView.swift
//  Host
//
//  Created by Leo Mehlig on 06.11.22.
//

import SwiftUI
import LocalizedTimeZones
import CoreLocation
import MapKit


struct ContentView: View {
    
    var cont: Set<String> {
        Set(TimeZone.locationDictionary.keys.map({ $0.components(separatedBy: "/").first! }))
    }
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(Array(cont).sorted(), id: \.self) {
                        Text($0)
                    }
                }
                .onAppear {
                  print(Set(TimeZone.knownTimeZoneIdentifiers.map({ $0.components(separatedBy: "/").first! })))
                }
                ForEach(TimeZone.knownTimeZoneLocations.filter({ $0.timeZone.symbol == "globe" })) { location in
                    NavigationLink(destination: {
                        self.map(for: location.coordinates)
                    }) {
                        VStack(spacing: 6) {
                            HStack {
                                Image(systemName: location.timeZone.symbol)
                                Text("\(location.localizedCity), \(location.localizedCountry)")
                                    .font(.headline)
                                Spacer()
                                Text(location.timeZone.localizedName(for: .shortStandard, locale: .current) ?? "")
                                    .font(.body)
                            }
                            HStack {
                                Text(location.identifier)
//                                Text(String(format: "%.2f, %.2f", location.coordinates.longitude, location.coordinates.latitude))
//                                    .foregroundColor(.secondary)
//                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func map(for coordinates: CLLocationCoordinate2D) -> some View {
        let region = MKCoordinateRegion(
            center: coordinates,
            latitudinalMeters: 10_000,
            longitudinalMeters: 10_000
        )
        return Map(coordinateRegion: .constant(region))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
