//
//  UpcomingBadge.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI

public struct UpcomingBadge: View {
    
    @State private var isAnimating: Bool = false
    
    private let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public var body: some View {
        
        HStack(spacing: 6) {
            
            Text(date.formatted(
                .dateTime
                    .day(.twoDigits)
                    .month(.twoDigits)
                    .hour(.twoDigits(amPM: .abbreviated))
                    .minute(.twoDigits)
            ))
                .font(.caption.weight(.bold))
                .foregroundColor(.primary)
            
//            Text("in 5 min")
//                .font(.caption.weight(.bold))
//                .foregroundColor(.white)
            
        }
        .padding(.horizontal, 6)
        .padding(.leading, 2)
        .padding(.vertical, 2)
        .background(Color.tertiarySystemBackground)
        .cornerRadius(4)
        
    }
    
}

struct UpcomingBadge_Previews: PreviewProvider {
    static var previews: some View {
        
        UpcomingBadge(date: Date(timeIntervalSinceNow: 5 * 60))
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
        
        UpcomingBadge(date: Date(timeIntervalSinceNow: 5 * 60))
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
    }
}
