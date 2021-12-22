//
//  RubbishCalendarItem.swift
//  RubbishFeature
//
//  Created by Lennart Fischer on 22.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI

public struct RubbishCalendarItem: View {

    @ScaledMetric var rubbishIconSize: CGFloat = 44

    private let item: RubbishPickupItem
    
    public init(item: RubbishPickupItem) {
        self.item = item
    }
    
    public var body: some View {
        
        let wasteType = item.type
        
        VStack(alignment: .center) {
            
            Text(item.date, formatter: Self.shortRubbishDateFormatter)
                .multilineTextAlignment(.center)
            //                .foregroundColor(.secondary)
                .font(.footnote.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
                .foregroundColor(Color.white)
                .background(Color(UIColor.tertiarySystemBackground))
            
            VStack {
                
                RubbishTypeIcon(type: wasteType)
                    .frame(
                        maxWidth: rubbishIconSize,
                        maxHeight: rubbishIconSize
                    )
                
                Text(wasteType.shortName)
                    .multilineTextAlignment(.center)
                    .font(.footnote.weight(.semibold))
                
            }
            .padding(8)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.quaternarySystemFill))
        .cornerRadius(8)
        
    }
    
    public static let shortRubbishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
}

struct RubbishCalendarItem_Previews: PreviewProvider {
    static var previews: some View {
        RubbishCalendarItem(item: RubbishPickupItem(
            date: Date(timeIntervalSinceNow: 2 * 24 * 60 * 60),
            type: .paper
        ))
    }
}
