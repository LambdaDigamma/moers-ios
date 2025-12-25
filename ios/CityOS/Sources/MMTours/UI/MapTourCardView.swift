//
//  MapTourCardView.swift
//  
//
//  Created by Lennart Fischer on 18.12.20.
//

import SwiftUI
import MMCommon
import MapKit

public struct MapTourCardView: View {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.4401348,
            longitude: 6.6186238
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005
        )
    )
    
    public init() {
        
    }
    
    @State private var tour: Tour = Tour(stations: [
        Station(id: 1,
                 name: "ENNI Eventhalle",
                 latitude: 51.4401348,
                 longitude: 6.6186238)
    ])
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            Map(coordinateRegion: $region,
                interactionModes: [],
                showsUserLocation: false,
                annotationItems: tour.stations) { (location) -> MapMarker in
                
                MapMarker(coordinate: location.coordinate, tint: .red)
                
            }
            .frame(height: 200)
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    (Text("Karte der Ausstellungsorte ") + Text(Image(systemName: "chevron.right").resizable()))
                        .font(.title)
                    Text("Auf der Karte findest Du die einzelnen Orte und kannst schnell eine Navigation starten.")
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                }
                Spacer()
                
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            
        }
        
        .cornerRadius(12)
        
    }
}

struct MapTourCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            MapTourCardView()
                .padding(20)
                .navigationBarTitle("Ausstellung")
        }
        .environment(\.colorScheme, .dark)
        
    }
}
