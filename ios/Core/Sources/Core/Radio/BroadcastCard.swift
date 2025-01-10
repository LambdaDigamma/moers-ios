//
//  BroadcastCard.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI
import NukeUI

public struct BroadcastCard: View {
    
    private let source: String
    private let title: String
    
    private let imageURL: URL?
    
    public init(source: String, title: String = "") {
        self.source = source
        self.title = title
        self.imageURL = URL(string: source)
    }
    
    public var body: some View {
        
        VStack {
            
            LazyImage(
                url: imageURL,
                resizingMode: .aspectFill
            )
                .frame(idealWidth: 200, idealHeight: 150)
                .cornerRadius(6)
            
            Text(title)
                .font(.footnote.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
            
        }.frame(maxWidth: 200, maxHeight: 180, alignment: .leading)
        
    }
    
}

struct BroadcastCard_Preview: PreviewProvider {
    
    static var previews: some View {
        
        BroadcastCard(source: "https://www.nrwision.de/fileadmin/_processed_assets_/4/3/csm_thumb_buergerradiomeerbeck_a_02_2021.mp3_09fb752572.jpg", title: "Some title")
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        
    }
    
}
