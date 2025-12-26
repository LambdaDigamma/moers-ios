//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Factory
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
        action: @escaping () -> Void
    ) {
        self.action = action
        self.coordinate = coordinate
        self.directionsMode = directionsMode
        self._viewModel = .init(
            wrappedValue: .init(
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

#Preview {
    
    Container.shared.locationService.register {
        let locationService = StaticLocationService()
        locationService.location = .init(.init(latitude: 51.451150, longitude: 6.614330))
        return locationService
    }
    
    return AutoCalculatingDirectionsButton(
        coordinate: .init(latitude: 51.449711, longitude: 6.629624),
        action: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
    
}
