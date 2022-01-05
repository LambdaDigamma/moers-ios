//
//  PetrolPriceDashboardView.swift
//  
//
//  Created by Lennart Fischer on 21.12.21.
//

import SwiftUI

public struct PetrolPriceDashboardView: View {
    
    @ObservedObject var viewModel: PetrolPriceDashboardViewModel
    
    public init(viewModel: PetrolPriceDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        CardPanelView {
            
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("\(Image(systemName: "location.fill")) Aktueller Ort")
                            .font(.callout.weight(.medium))
                        
                        Text("Moers")
                            .font(.title.weight(.bold))
                        
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        
                        let price = viewModel.data.value?.averagePrice ?? 1.45
                        
                        Text(String(format: "%.2f€", price))
                            .redacted(reason: viewModel.data.loading ? .placeholder : [])
                            .font(.title.weight(.bold))
                        
                        Text("pro L Diesel".uppercased())
                            .foregroundColor(.secondary)
                            .font(.caption.weight(.medium))
                        
                    }
                    
                }
                
                Text("21 Tankstellen in Deiner näheren Umgebung haben geöffnet.")
                    .foregroundColor(.secondary)
                    .font(.callout)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
        }
        .onAppear {
            viewModel.load()
        }
        
    }
    
}

struct CardPanelView<Content: View>: View {
    
    var content: Content
    
    init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    var body: some View {
        
        ZStack {
            self.content
        }
        .frame(maxWidth: .infinity)
//        .background(Color("Card"))
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
        
    }
    
}

struct PetrolPriceDashboardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let service = StaticPetrolService()
        let viewModel = PetrolPriceDashboardViewModel(
            petrolService: service,
            initialState: .loading
        )
        
        PetrolPriceDashboardView(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .padding()
            .previewLayout(.sizeThatFits)
        
    }
    
}
