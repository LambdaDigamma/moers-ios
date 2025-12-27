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
    @State var showParkingTimer: Bool = false
    
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
        .ignoresSafeArea(.container, edges: .top)
        .background(ApplicationTheme.current.dashboardBackground)
        .navigationTitle(Text(PackageStrings.ParkingAreaList.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarItem()
        }
        .task {
            viewModel.load()
        }
        .sheet(isPresented: $showParkingTimer) {
            NavigationView {
                ParkingTimerScreen()
                    .toolbar(content: {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: { showParkingTimer = false }) {
                                Text(PackageStrings.close)
                            }
                        }
                    })
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        
    }
    
    @ViewBuilder
    private func freeLiveParkingAreasGrid() -> some View {
        
        VStack(alignment: .leading) {
            
            if viewModel.userGrantedLocation {
                Text(PackageStrings.ParkingAreaList.titleNearYou)
                    .font(.title3.weight(.semibold))
            } else {
                Text(PackageStrings.ParkingAreaList.title)
                    .font(.title3.weight(.semibold))
            }
            
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                
                ForEach(viewModel.parkingAreas) { viewModel in
                    
                    NavigationLink {
                        
                        ParkingAreaDetailScreen(viewModel: viewModel)
                        
                    } label: {
                        
                        CardPanelView {
                            ParkingAreaDetail(viewModel: viewModel)
                        }
                        .frame(maxWidth: .infinity)
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
            .frame(idealHeight: 400)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color.clear,
                        ApplicationTheme.current.dashboardBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 44)
            }
        
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
        
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            
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
                .foregroundColor(Color.yellow)
            }
            
            Button(action: {
                showParkingTimer = true
            }) {
                Image(systemName: "timer")
                    .foregroundColor(Color.yellow)
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
