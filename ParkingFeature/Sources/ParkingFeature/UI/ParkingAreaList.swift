//
//  ParkingAreaList.swift
//  
//
//  Created by Lennart Fischer on 14.01.22.
//

import SwiftUI
import MapKit
import Core

public struct ParkingAreaList: View {
    
    @ObservedObject private var viewModel: ParkingAreaListViewModel
    
    private let gridSpacing: CGFloat = 16
    
    public init(
        parkingService: ParkingService,
        locationService: LocationService? = nil
    ) {
        
        self.viewModel = ParkingAreaListViewModel(
            parkingService: parkingService,
            locationService: locationService
        )
        
    }
    
    var columns: [GridItem] {
        return [
            .init(
                .flexible(minimum: 50, maximum: 400),
                spacing: gridSpacing
             ),
            .init(
                .flexible(minimum: 50, maximum: 400),
                spacing: gridSpacing
            ),
        ]
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack(spacing: 0) {
                
                map()
                
                freeLiveParkingAreasGrid()
                    .padding([.leading, .trailing, .top])
                
                disclaimer()
                    .padding()
                
            }
            
        }
        .navigationTitle(Text(PackageStrings.ParkingAreaList.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarItem()
        }
        .onAppear {
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    private func freeLiveParkingAreasGrid() -> some View {
        
        VStack(alignment: .leading) {
            
            if viewModel.userGrantedLocation {
                Text("Freie Parkplätze in Deiner Nähe")
                    .font(.title3.weight(.semibold))
            } else {
                Text("Freie Parkplätze")
                    .font(.title3.weight(.semibold))
            }
            
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                
                ForEach(viewModel.parkingAreas) { viewModel in
                    
                    NavigationLink {
                        
                        ParkingAreaDetailScreen(viewModel: viewModel)
                        
                    } label: {
                        
                        ParkingAreaDetail(viewModel: viewModel)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                            .foregroundColor(Color(UIColor.label))
                        
                    }
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func map() -> some View {
        
        BaseMap(
            viewModel: viewModel.mapViewModel,
            region: $viewModel.region,
            userTrackingMode: .constant(.none)
        )
            .mapType(.standard)
            .showsUserLocation(true)
            .frame(idealHeight: 300)
        
//        Map(
//            coordinateRegion: $viewModel.region,
//            interactionModes: [],
//            showsUserLocation: true
//        )
//            .frame(idealHeight: 300)
        
//            .overlay(
//                ZStack(alignment: .bottom) {
//
//                    VStack {
//                        Text("Parkplätze auf Karte ansehen \(Image(systemName: "chevron.forward"))")
//                            .fontWeight(.semibold)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
//                    .background(Color(UIColor.secondarySystemBackground))
//
//                }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//            )
        
    }
    
    @ViewBuilder
    private func disclaimer() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text(PackageStrings.ParkingAreaList.disclaimer)
            Text(PackageStrings.ParkingAreaList.dataSource)
        }
        .font(.caption)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color(UIColor.tertiaryLabel))
        
    }
    
    private func toolbarItem() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            
            Menu {
                
                Picker(
                    selection: $viewModel.filter,
                    label: Text(PackageStrings.ParkingAreaList.filterDescription)
                ) {
                    
                    ForEach(ParkingAreaFilterType.allCases, id: \.self) { filter in
                        Text(filter.title)
                    }
                    
                }
                
            } label: {
                Label(PackageStrings.ParkingAreaList.filter,
                      systemImage: "line.3.horizontal.decrease.circle")
            }
            
        }
        
    }
    
}

struct ParkingAreaList_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            ParkingAreaList(parkingService: StaticParkingService(), locationService: nil)
                .preferredColorScheme(.dark)
        }
        
    }
}
