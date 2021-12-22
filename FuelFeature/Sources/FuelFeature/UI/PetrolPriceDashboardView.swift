//
//  PetrolPriceDashboardView.swift
//  
//
//  Created by Lennart Fischer on 21.12.21.
//

import SwiftUI

public struct PetrolPriceDashboardView: View {
    
    public init() {
        
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
                        
                        Text("1.55€")
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
        PetrolPriceDashboardView()
    }
}
