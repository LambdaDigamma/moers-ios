//
//  Pill.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI

public struct Pill: View {
    
    public let text: Text
    public let background: Color
    
    public var body: some View {
        
        text
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(background)
            .cornerRadius(16)
        
    }
    
}

struct Pill_Previews: PreviewProvider {
    static var previews: some View {
        Pill(text: Text("Hallo"), background: .blue)
            .foregroundColor(.white)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
