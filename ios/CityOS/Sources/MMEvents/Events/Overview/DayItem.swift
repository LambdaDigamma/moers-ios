//
//  DaySelector.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

struct DayItem: View {
    
    var date: Date
    var isActive: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .callout) private var circleDiameter: CGFloat = 44
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 4) {
            
            Text(date, format: .dateTime.day())
            .font(.callout)
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundColor(.primary)
            .lineLimit(1)
            .fixedSize()
            .frame(width: max(44, circleDiameter), height: max(44, circleDiameter))
            .background(alignment: .center) {
                Circle()
                    .fill(isActive ? activeColor : Color.tertiarySystemFill)
            }
            
            Text(date, format: .dateTime.weekday(.abbreviated))
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .lineLimit(1)
            .fixedSize()
            
        }
        .frame(minWidth: max(44, circleDiameter))
        .fixedSize()
        
    }
    
    var activeColor: Color {
        
        switch colorScheme {
            case .light:
                return Color.yellow.opacity(0.2)
            case .dark:
                return Color.yellow.opacity(0.3)
            @unknown default:
                return Color.yellow.opacity(0.2)
        }
        
    }
    
}

struct DayItem_Previews: PreviewProvider {
    static var previews: some View {
        DayItem(date: Date())
            .padding()
            .previewLayout(.sizeThatFits)
        
        DayItem(date: Date(), isActive: true)
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Active")
    }
}
