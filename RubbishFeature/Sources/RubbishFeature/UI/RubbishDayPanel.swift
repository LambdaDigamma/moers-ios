//
//  RubbishDayPanel.swift
//  
//
//  Created by Lennart Fischer on 22.12.21.
//

import SwiftUI

public struct RubbishDayPanel: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
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
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(8)
            
            Divider()
            
            VStack(spacing: 4) {
                
                ForEach(items) { item in
                    wasteBannerTranslucent(wasteType: item.type)
                }
                
            }
            .padding(.bottom, 4)
            .padding(.top, 8)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        
    }
    
    @ViewBuilder
    private func wasteBannerTranslucent(
        wasteType: RubbishWasteType
    ) -> some View {
        
        Text(wasteType.shortName)
            .font(.footnote.weight(.semibold))
            .padding(4)
            .padding(.leading, 12)
            .foregroundColor(colorScheme == .light ? .black : .white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ZStack(alignment: .leading) {
                Rectangle()
                    .fill(wasteType.backgroundColor)
                    .frame(idealWidth: 4, maxWidth: 4, maxHeight: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity, alignment: .leading))
            .background(
                wasteType.backgroundColor.opacity(
                    colorScheme == .light ? 0.25 : 0.15
                )
            )
        
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
