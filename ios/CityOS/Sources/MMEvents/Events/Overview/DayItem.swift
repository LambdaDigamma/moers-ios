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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 4) {
            
            Text(
                date.formatted(
                    .dateTime
                        .day()
                )
            )
            .font(.callout)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding(12)
            .background(alignment: .center) {
                Circle()
                    .fill(isActive ? activeColor : Color.tertiarySystemFill)
            }
            
            Text(
                date.formatted(
                    .dateTime.weekday(.abbreviated)
                )
            )
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            
        }
        
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
