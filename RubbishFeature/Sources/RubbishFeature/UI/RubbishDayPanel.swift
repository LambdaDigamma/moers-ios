//
//  RubbishDayPanel.swift
//  
//
//  Created by Lennart Fischer on 22.12.21.
//

import SwiftUI

public struct RubbishDayPanel: View {
    
    private let date: String
    private let items: [RubbishPickupItem]
    
    public init(date: String, items: [RubbishPickupItem]) {
        self.date = date
        self.items = items
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            Text(date)
                .font(.footnote.weight(.semibold))
                .padding(8)
            
            Divider()
//                .background(Color.yellow)
            
            VStack(spacing: 4) {
                
                ForEach(items) { item in
                    wasteBannerTranslucent(wasteType: item.type)
                }
                
            }
            .padding(.bottom, 8)
            .padding(.top, 8)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .cornerRadius(8)
//        .background(Color(UIColor.systemBackground))
        
    }
    
    @ViewBuilder
    private func wasteBanner(text: String, backgroundColor: Color, foregroundColor: Color) -> some View {
        
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(4)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(backgroundColor)
        
    }
    
    @ViewBuilder
    private func wasteBannerTranslucent(
        wasteType: RubbishWasteType
    ) -> some View {
        
        Text(wasteType.shortName)
            .font(.footnote.weight(.semibold))
            .padding(4)
            .padding(.leading, 12)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ZStack(alignment: .leading) {
                Rectangle()
                    .fill(wasteType.backgroundColor)
                    .frame(width: 4, height: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading))
            .background(wasteType.backgroundColor.opacity(0.15))
        
    }
    
}

struct RubbishDayPanel_Previews: PreviewProvider {
    static var previews: some View {
        
        HStack(spacing: 8) {
            
            RubbishDayPanel(date: "Morgen", items: [
                .init(date: Date(), type: .plastic),
                .init(date: Date(), type: .paper),
            ])
            
            RubbishDayPanel(date: "24.12.", items: [
                .init(date: Date(), type: .organic),
            ])
            
            RubbishDayPanel(date: "25.12.", items: [
            ])
            
        }
        .padding()
        .frame(maxWidth: 350, maxHeight: 150)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
            
    }
}
