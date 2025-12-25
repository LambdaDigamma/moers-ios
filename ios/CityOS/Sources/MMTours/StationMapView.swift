//
//  StationMapView.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import MapKit
import MMTours

struct StationMapView: View {
    
    @State private var stations: [Station] = [
        Station(id: 1,
                name: "ENNI Eventhalle",
                latitude: 51.4401348,
                longitude: 6.6186238)
    ]
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 25.7617, longitude: 80.1918),
//        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
//    )
    
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
    
    var body: some View {
//        Map(coordinateRegion: $region, annotationItems: stations) { city in
//
//
//            MapAnnotation(
//                coordinate: city.coordinate,
//                anchorPoint: CGPoint(x: 0.5, y: 0.5)
//            ) {
//                Circle()
//                    .fill(Color.green)
//                    .frame(width: 44, height: 44)
//            }
//        }
        
        
        Map(coordinateRegion: $region,
            interactionModes: [],
            showsUserLocation: false,
            annotationItems: stations) { (location) -> MapMarker in

            MapMarker(coordinate: location.coordinate, tint: .red)

        }.ignoresSafeArea()
    }
    
}

struct StationMapView_Previews: PreviewProvider {
    static var previews: some View {
        StationMapView()
    }
}


//@State private var region = MKCoordinateRegion(
//    center: CLLocationCoordinate2D(
//        latitude: 51.4401348,
//        longitude: 6.6186238
//    ),
//    span: MKCoordinateSpan(
//        latitudeDelta: 0.005,
//        longitudeDelta: 0.005
//    )
//)
//
//public init() {
//
//}
//
//@State private var tour: Tour = Tour(stations: [
//    Station(id: 1,
//            name: "ENNI Eventhalle",
//            latitude: 51.4401348,
//            longitude: 6.6186238)
//])
//
//public var body: some View {
//
//    VStack(spacing: 0) {
//
//        Map(coordinateRegion: $region,
//            interactionModes: [],
//            showsUserLocation: false,
//            annotationItems: tour.stations) { (location) -> MapMarker in
//
//            MapMarker(coordinate: location.coordinate, tint: .red)
//
//        }
//        .frame(height: 200)
//
//        HStack(alignment: .top, spacing: Margin.medium) {
//            VStack(alignment: .leading, spacing: Margin.standard) {
//                (Text("Karte der Ausstellungsorte ") + Text(Image(systemName: "chevron.right").resizable()))
//                    .font(Typography.style(.title))
//                Text("Auf der Karte findest Du die einzelnen Orte und kannst schnell eine Navigation starten.")
//                    .font(Typography.style(.footnote))
//                    .foregroundColor(Color(.secondaryLabel))
//            }
//            Spacer()
//
//        }
//        .padding(Margin.wide)
//        .background(Color(.secondarySystemBackground))
//
//    }
//
//    .cornerRadius(12)
//
//}
