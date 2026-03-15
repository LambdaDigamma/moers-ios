//
//  LocationDetailScreen.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import SwiftUI
import MMEvents
import MMPages

public struct VenueDetailScreen: View {
    
    @ObservedObject var viewModel: VenueDetailViewModel
    
    public let onSelectEvent: (Event.ID) -> Void
    private let actionTransmitter: ActionTransmitter
    
    public init(
        viewModel: VenueDetailViewModel,
        actionTransmitter: ActionTransmitter,
        onSelectEvent: @escaping (Event.ID) -> Void
    ) {
        self.viewModel = viewModel
        self.actionTransmitter = actionTransmitter
        self.onSelectEvent = onSelectEvent
    }
    
    public var body: some View {
        
        ScrollView {
            LazyVStack(spacing: 0) {
                
                map()
                    .preferredColorScheme(.light)
                
                header()
                
                if viewModel.point != nil,
                    viewModel.point?.latitude != 0,
                    viewModel.point?.longitude != 0 {
                    navigation()
                }
                
                page()
                
                events()
                
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    @ViewBuilder
    private func map() -> some View {
        
        if let point = viewModel.point, point.latitude != 0, point.longitude != 0 {
            
            MapSnapshotView(
                location: point.toCoordinate(),
                span: 0.001,
                annotations: [SnapshotAnnotation(point: point)],
                poiFilter: .excludingAll
            )
            .frame(height: 250)
            
        }
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading) {
                
                Text(viewModel.subtitle)
                    .foregroundColor(.secondary)
                
                if let addressLine2 = viewModel.addressLine2 {
                    Text(addressLine2)
                }
                
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        
    }
    
    @ViewBuilder
    private func page() -> some View {
        
        if let pageID = viewModel.pageID {
            
            IsolatedNativePageView(pageID: pageID)
                .environmentObject(actionTransmitter)
                .environment(\.openURL, OpenURLAction { url in
                    actionTransmitter.dispatchOpenURL(url)
                    return .handled
                })
            
        }
        
    }
    
    @ViewBuilder
    private func navigation() -> some View {
        
        if let point = viewModel.point {
            
            AutoCalculatingDirectionsButton(
                coordinate: point.toCoordinate(),
                directionsMode: .walking,
                action: {
                    AppleNavigationProvider().startNavigation(to: point, withName: viewModel.name)
                }
            )
            .padding(.horizontal)
            
        }
        
    }
    
    @ViewBuilder
    private func events() -> some View {
        
        GroupedEventCollection(
            viewModels: viewModel.events,
            onSelectEvent: { (eventID: Event.ID) in
                self.onSelectEvent(eventID)
            }
        )
            .padding(.top, 32)
            .background(Color(UIColor.secondarySystemBackground))
            .padding(.top, 16)
            
        
    }
    
}

struct VenueDetailScreen_Previews: PreviewProvider {
    
    static let viewModel: VenueDetailViewModel = {
        let viewModel = VenueDetailViewModel(placeID: 1)
        viewModel.name = "Festivalhalle"
        viewModel.subtitle = "Filderstraße 142"
        viewModel.point = Point(latitude: 51.440105, longitude: 6.619091)
        return viewModel
    }()
    
    static var previews: some View {
        
        NavigationView {
            
            VenueDetailScreen(
                viewModel: viewModel,
                actionTransmitter: ActionTransmitter(),
                onSelectEvent: { _ in }
            )
            
        }
        .preferredColorScheme(.light)
        
    }
    
}
