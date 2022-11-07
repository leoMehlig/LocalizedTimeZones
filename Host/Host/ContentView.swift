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
    var body: some View {
        NavigationView {
            List {
                Text(TimeZone.current.location?.localizedCity ?? "")
                ForEach(TimeZone.knownTimeZoneLocations) { location in
                    NavigationLink(destination: {
                        self.map(for: location.coordinates)
                    }) {
                        VStack(spacing: 6) {
                            HStack {
                                Text("\(location.localizedCity), \(location.localizedCountry)")
                                    .font(.headline)
                                Spacer()
                                Text(location.timeZone.localizedName(for: .shortStandard, locale: .current) ?? "")
                                    .font(.body)
                            }
                            HStack {
                                Text(String(format: "%.2f, %.2f", location.coordinates.longitude, location.coordinates.latitude))
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
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
