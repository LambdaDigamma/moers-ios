//
//  OpenBadge.swift
//  
//
//  Created by Lennart Fischer on 13.08.22.
//

import SwiftUI

public struct OpenBadge: View {
    
    private let isOpen: Bool
    
    public init(
        isOpen: Bool
    ) {
        self.isOpen = isOpen
    }
    
    var text: String {
        if isOpen {
            return AppStrings.OpeningState.open
        } else {
            return AppStrings.OpeningState.closed
        }
    }
    
    var backgroundColor: Color {
        if isOpen {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    var foregroundColor: Color {
        if isOpen {
            return Color.black
        } else {
            return Color.white
        }
    }
    
    public var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
}

struct OpenBadge_Previews: PreviewProvider {
    static var previews: some View {
        OpenBadge(isOpen: true)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        OpenBadge(isOpen: false)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
