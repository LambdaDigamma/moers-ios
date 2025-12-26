//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 29.01.22.
//

import SwiftUI
import Factory
import Core
import MapKit

public struct FuelStationList: View {
    
    @ObservedObject var viewModel: FuelPriceDashboardViewModel
    
    public init(viewModel: FuelPriceDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVGrid(columns: columns, spacing: 16) {
                
                if let fuelStations = viewModel.fuelStations.value {
                    
                    ForEach(fuelStations) { (fuelStation: FuelFeature.PetrolStation) in
                        
                        NavigationLink {
                            
                            FuelStationDetailScreen(
                                load: { viewModel.loadFuelStation(id: fuelStation.id) }
                            )
                            
                        } label: {
                            
                            stationCard(fuelStation: fuelStation)
                            
                        }
                        
                    }
                    
                }
                
            }
            .padding()
            
            Text(PackageStrings.dataSource)
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom)
            
        }
        .navigationTitle(PackageStrings.FuelStationList.title)
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    private var columns: [GridItem] {
        return Array(
            repeating: GridItem(.flexible(minimum: 100, maximum: 600),
                                spacing: 16,
                                alignment: .topTrailing),
            count: 1
        )
    }
    
    @ViewBuilder
    private func stationCard(
        fuelStation: FuelFeature.PetrolStation
    ) -> some View {
        
        VStack {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(fuelStation.title ?? fuelStation.brand)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    VStack(alignment: .leading) {
                        
                        Text("\(fuelStation.brand) • \(fuelStation.isOpen ? AppStrings.OpeningState.open : AppStrings.OpeningState.closed)")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        if let subtitle = fuelStation.subtitle {
                            Text(subtitle)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        
                    }
                    .font(.callout)
                    
                }
                
                Spacer()
                
                if let price = fuelStation.price {
                    
                    Text(String(format: "%.2f€", price))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(4)
                    
                }
                
            }
            
        }
        .padding()
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .contextMenu {
            Button {
                startNavigation(to: fuelStation)
            } label: {
                Label(PackageStrings.FuelStationList.contextNavigationAction,
                      systemImage: "arrow.triangle.turn.up.right.circle")
            }
        }
        
    }
    
    private func startNavigation(to fuelStation: PetrolStation) {
        fuelStation.startNavigation(mode: .default)
    }
    
}

struct FuelStationList_Previews: PreviewProvider {
    static var previews: some View {
        
        let service = StaticPetrolService()
        let viewModel = FuelPriceDashboardViewModel(
            petrolService: service,
            locationService: StaticLocationService(),
            geocodingService: StaticGeocodingService(),
            initialFuelStations: .success([
                .stub(withID: "C5B7FF8B-9D7C-4485-A740-7601F221C40E")
                    .setting(\.brand, to: "Shell"),
                .stub(withID: "E01B9608-A2D1-4A21-9CF0-9DB39B0EF883")
                    .setting(\.brand, to: "Markant"),
                .stub(withID: "D682A96B-5CCE-4F18-9E6A-C9EEF98A447A")
                    .setting(\.brand, to: "Aral"),
            ])
        )
        
        FuelStationList(viewModel: viewModel)
            .preferredColorScheme(.dark)
    }
}
