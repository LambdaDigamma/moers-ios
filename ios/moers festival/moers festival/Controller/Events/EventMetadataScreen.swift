//
//  EventMetadataScreen.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import SwiftUI
import CoreLocation
import MMEvents

public struct EventMetadataScreen: View {
    
    @ObservedObject var viewModel: EventDetailViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    private let onShowPlace: (Place.ID) -> Void
    
    public init(
        viewModel: EventDetailViewModel,
        locationService: LocationService? = nil,
        onShowPlace: @escaping (Place.ID) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.onShowPlace = onShowPlace
    }
    
    public var body: some View {
        
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack {
                        
                        Divider()
//                        .padding(.leading)
                        
                        locationRow()
                        
                        Divider()
                            .padding(.leading)
                        
                        tickets()
                        
                        artistsRow()
                        
                        Divider()
                            .padding(.leading)
                        
                        dateRow()
                        
                    }
                }
                
                Divider()
                
                actions()
                
            }
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26.0, *) {
                        Button("Close", systemImage: "xmark") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Close")
                        }
                    }
                }
                
            })
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    @ViewBuilder
    private func locationRow() -> some View {
        
        Button(action: {
            
            if let placeID = viewModel.location?.id {
                presentationMode.wrappedValue.dismiss()
                onShowPlace(placeID)
            }
            
        }) {
            
            DetailEntry {
                Text(EventPackageStrings.locationHeader)
            } content: {
                
                if let locationName = viewModel.location?.name {
                    Text("\(locationName) \(Image(systemName: "chevron.right"))")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(EventPackageStrings.unknown)
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func tickets() -> some View {
        
        if let tickets = viewModel.event?.extras?.tickets {
            
            DetailEntry {
                Text(EventPackageStrings.ticketsHeader)
            } content: {
                
                Text(tickets)
                
            }
            
            Divider()
                .padding(.leading)
            
        }
        
    }
    
    @ViewBuilder
    private func artistsRow() -> some View {
        
        let artists = viewModel.event?.artists?.compactMap { $0 } ?? []
        
        DetailEntry {
            Text(EventPackageStrings.artistsHeader)
        } content: {
            Text(artists.joined(separator: "\n"))
        }
        
    }
    
    @ViewBuilder
    private func dateRow() -> some View {
        if let event = viewModel.event, event.showsDateComponent {
            DetailEntry {
                Text(EventPackageStrings.startHeader)
            } content: {
                if let startDate = event.startDate {
                    if event.showsTimeComponent {
                        Text(startDate, style: .time) +
                        Text(" (") +
                        Text(startDate, style: .date) + Text(")")
                    } else if let endDate = event.endDate, !Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                        Text(startDate, style: .date) +
                        Text(" - ") +
                        Text(endDate, style: .date)
                    } else {
                        Text(startDate, style: .date)
                    }
                } else {
                    Text(EventPackageStrings.unknown)
                }
            }
            
            if event.showsTimeComponent, let endDate = event.endDate, !event.isOpenEnd {
                
                Divider()
                    .padding(.leading)
                
                DetailEntry {
                    Text(EventPackageStrings.endHeader)
                } content: {
                    Text(endDate, style: .time) +
                    Text(" (") +
                    Text(endDate, style: .date) + Text(")")
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        VStack(alignment: .center) {
            
            if let coordinate = viewModel.location?.coordinate, let locationName = viewModel.location?.name {
                
                AutoCalculatingDirectionsButton(
                    coordinate: coordinate.toCoordinate(),
                    directionsMode: .walking,
                    action: {
                        AppleNavigationProvider()
                            .startNavigation(
                                to: coordinate,
                                withName: locationName
                            )
                    }
                )
                
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

public struct DetailEntry<Label: View, Content: View>: View {
    
    public var label: () -> Label
    public var content: () -> Content
    
    init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.content = content
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            label()
                .foregroundColor(.secondary)
                
            content()
                .font(.body.weight(.medium))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        
    }
    
}

//struct EventMetadataScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        EventMetadataScreen(
//            artists: ["Max Mustermann (voc)", "Greg Gimmy (g)"],
//            startDate: Date(timeIntervalSinceNow: 5 * 60),
//            endDate: Date(timeIntervalSinceNow: 50 * 60),
//            locationService: StaticLocationService()
//        )
//        .preferredColorScheme(.dark)
//    }
//}
