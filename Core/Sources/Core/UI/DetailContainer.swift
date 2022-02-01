//
//  DetailContainer.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import SwiftUI

public struct DetailContainer<Content: View>: View {
    
    private let title: String
    private var content: () -> Content
    
    public init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
                .unredacted()
            
            content()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct DetailContainer_Previews: PreviewProvider {
    static var previews: some View {
        DetailContainer(title: "Preise") {
            Text("Hallo")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
