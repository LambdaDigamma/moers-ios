//
//  TransitLocationMapView.swift
//  
//
//  Created by Lennart Fischer on 11.12.21.
//

import SwiftUI
import MapKit
import EFAAPI

public struct TransitLocationMapView: View {
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.5,
            longitude: -0.12
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.2,
            longitudeDelta: 0.2
        )
    )
    
    struct Location: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
    
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
    
//    private let transitLocations: [TransitLocation]
    
//    public init(transitLocations: [TransitLocation]) {
//        self.transitLocations = transitLocations
//    }
    
    public var body: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
            
            MapAnnotation(coordinate: location.coordinate) {
                Circle()
                    .stroke(.red, lineWidth: 3)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
}

struct TransitLocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        TransitLocationMapView()
    }
}
