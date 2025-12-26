//
//  FuelPriceDashboardView.swift
//  
//
//  Created by Lennart Fischer on 21.12.21.
//

import SwiftUI

public struct FuelPriceDashboardView: View {
    
    @ObservedObject var viewModel: FuelPriceDashboardViewModel
    
    public init(viewModel: FuelPriceDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        NavigationLink {
            
            FuelStationList(viewModel: viewModel)
            
        } label: {
            CardPanelView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("\(Image(systemName: "location.fill")) \(PackageStrings.Dashboard.currentLocation)")
                                .font(.callout.weight(.medium))
                            
                            Text(viewModel.locationName.value ?? "Moers")
                                .font(.title.weight(.bold))
                                .redacted(reason: viewModel.locationName.loading ? .placeholder : [])
                            
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            
                            let price = viewModel.data.value?.averagePrice ?? 1.45
                            
                            Text(String(format: "%.2f€", price))
                                .redacted(reason: viewModel.data.loading ? .placeholder : [])
                                .font(.title.weight(.bold))
                            
                            Text(PackageStrings.Dashboard.perL(viewModel.petrolType).uppercased())
                                .foregroundColor(.secondary)
                                .font(.caption.weight(.medium))
                            
                        }
                        
                    }
                    
                    Text(PackageStrings.Dashboard.stationsNearYou(viewModel.data.value?.numberOfStations ?? 20))
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .redacted(reason: viewModel.data.loading ? .placeholder : [])
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
            }
            .task {
                viewModel.load()
            }
        }
        .foregroundColor(Color.primary)
        
    }
    
}

struct CardPanelView<Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var content: Content
    
    init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    var body: some View {
        
        ZStack {
            self.content
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(radius: colorScheme == .light ? 8 : 0)
        
    }
    
}

struct FuelPriceDashboardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let service = StaticPetrolService()
        let viewModel = FuelPriceDashboardViewModel(
            petrolService: service,
            initialState: .loading
        )
        
        FuelPriceDashboardView(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .padding()
            .previewLayout(.sizeThatFits)
        
    }
    
}
