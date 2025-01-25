//
//  BigTrackBadge.swift
//  
//
//  Created by Lennart Fischer on 25.12.22.
//

import SwiftUI

public struct BigTrackBadge: View {
    
    public let track: String
    public let accent: Color
    public let onAccent: Color
    
    public init(
        track: String,
        accent: Color,
        onAccent: Color
    ) {
        self.track = track
        self.accent = accent
        self.onAccent = onAccent
    }
    
    public var body: some View {
        
        VStack {
            
            Text("Gleis".uppercased())
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(track)
                .font(.largeTitle)
                .fontWeight(.heavy)
            
        }
        .foregroundColor(onAccent)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(accent)
        .cornerRadius(8)
        
    }
    
}
