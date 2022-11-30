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
import Contacts


struct ContentView: View {
    
    var unknown: [String] {
        TimeZone.knownTimeZoneIdentifiers.filter({ TimeZone(identifier: $0)?.location == nil })
    }
  
    var body: some View {
        NavigationView {
            List {
                Section {
                    DisclosureGroup("Unknown Identifiers") {
                        ForEach(Array(unknown).sorted(), id: \.self) {
                            Text($0)
                        }
                    }
                }
                .task {
//                    await TimeZone.loadMissing()
                }
                ForEach(TimeZone.knownTimeZoneLocations) { location in
                    NavigationLink(destination: {
                        self.map(for: location.coordinates)
                    }) {
                        VStack(spacing: 6) {
                            HStack {
                                Image(systemName: location.timeZone.symbol)
                                Text("\(location.localizedCity), \(location.localizedCountry)")
                                    .font(.headline)
                                Spacer()
                                Text(location.timeZone.localizedName(for: .shortGeneric, locale: .current) ?? "")
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
