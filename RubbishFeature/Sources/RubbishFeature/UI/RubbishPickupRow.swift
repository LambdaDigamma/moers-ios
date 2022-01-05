//
//  RubbishPickupRow.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import SwiftUI

public struct RubbishPickupRow: View {
    
    @ScaledMetric var iconSize: CGFloat = 44
    
    private let item: RubbishPickupItem
    
    public init(item: RubbishPickupItem) {
        self.item = item
    }
    
    public var body: some View {
        
        HStack(alignment: .center) {
            
            RubbishTypeIcon(type: item.type)
                .frame(width: iconSize)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(RubbishWasteType.localizedForCase(item.type))
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(DateFormatter.localizedString(
                    from: item.date,
                    dateStyle: .full,
                    timeStyle: .none)
                )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct RubbishPickupRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let item = RubbishPickupItem(
            date: .init(timeIntervalSinceNow: 1 * 24 * 60 * 60),
            type: .residual
        )
        
        RubbishPickupRow(item: item)
            .padding()
            .previewLayout(.sizeThatFits)
        
        RubbishPickupRow(item: item)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
    }
    
}
