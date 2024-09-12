//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 21.12.21.
//

import SwiftUI
import Core

public struct HorizontalPickupItems: View {
    
    @ScaledMetric var rubbishIconSize: CGFloat = 44
    
    private let items: [RubbishPickupItem]
    
    public init(items: [RubbishPickupItem]) {
        self.items = items
    }
    
    public var body: some View {
        
        let firstThreeItems = Array(items.prefix(3))
        
        HStack(alignment: .top) {
            
            if let first = firstThreeItems[safeIndex: 0] {
                RubbishCalendarItem(item: first)
                Spacer(minLength: 12)
            }
            
            if let second = firstThreeItems[safeIndex: 1] {
                RubbishCalendarItem(item: second)
                Spacer(minLength: 12)
            }
            
            if let third = firstThreeItems[safeIndex: 2] {
                RubbishCalendarItem(item: third)
            }
            
        }
        
    }
    
    public static let shortRubbishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
}

struct HorizontalPickupItems_Previews: PreviewProvider {
    static var previews: some View {
        
        let items = [
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 1 * 24 * 60),
                type: .paper
            ),
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 1 * 24 * 60),
                type: .plastic
            ),
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 2 * 24 * 60),
                type: .organic
            )
        ]
        
        HorizontalPickupItems(items: items)
            .padding()
            .previewLayout(.sizeThatFits)
        
        HorizontalPickupItems(items: items)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
    }
}
