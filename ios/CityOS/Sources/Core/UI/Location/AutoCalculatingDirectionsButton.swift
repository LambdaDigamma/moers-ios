//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import SwiftUI
import CoreLocation
import MapKit

public struct AutoCalculatingDirectionsButton: View {
    
    @StateObject var viewModel: DirectionsViewModel
    
    private let coordinate: CLLocationCoordinate2D
    private let directionsMode: DirectionsMode
    private let action: () -> Void
    
    public init(
        coordinate: CLLocationCoordinate2D,
        directionsMode: DirectionsMode = .driving,
        locationService: LocationService,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.coordinate = coordinate
        self.directionsMode = directionsMode
        self._viewModel = .init(
            wrappedValue: .init(
                locationService: locationService,
                directionsMode: directionsMode
            )
        )
    }
    
    public var body: some View {
        
        GetDirectionsButton(
            action: action,
            travelTime: viewModel.eta.value,
            mode: directionsMode
        )
        .task {
            viewModel.getETAFromUserLocation(to: coordinate)
        }
    }
    
}

struct AutoCalculatingDirectionsButton_Previews: PreviewProvider {
    static var previews: some View {
        
        let locationService = StaticLocationService()
        locationService.location = .init(.init(latitude: 51.451150, longitude: 6.614330))
        
        return AutoCalculatingDirectionsButton(
            coordinate: .init(latitude: 51.449711, longitude: 6.629624),
            locationService: locationService,
            action: {}
        )
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
