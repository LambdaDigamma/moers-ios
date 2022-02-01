//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import SwiftUI
import CoreLocation

public struct AutoCalculatingDirectionsButton: View {
    
    @StateObject var viewModel: DirectionsViewModel
    
    private let coordinate: CLLocationCoordinate2D
    private let action: () -> Void
    
    public init(
        coordinate: CLLocationCoordinate2D,
        locationService: LocationService,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.coordinate = coordinate
        self._viewModel = .init(wrappedValue: .init(locationService: locationService))
    }
    
    public var body: some View {
        
        GetDirectionsButton(
            action: action,
            travelTime: viewModel.eta.value,
            mode: .driving
        )
            .onAppear {
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
    }
}
