//
//  DefaultProgressView.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import SwiftUI

public struct DefaultProgressView: View {
    
    private let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        
        VStack(alignment: .center, spacing: 12) {
            
            ProgressView()
                .progressViewStyle(.circular)
            
            Text(text)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        
    }
}

struct DefaultProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        DefaultProgressView(text: "Loading component…")
            .padding()
            .previewLayout(.sizeThatFits)
    }
    
}
