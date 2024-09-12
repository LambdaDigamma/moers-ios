//
//  InsetNewsListItem.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
//import NewsWidgets

struct InsetNewsListItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let viewModel: NewsViewModel
    
    var body: some View {
        Link(destination: viewModel.link, label: {
            GeometryReader(content: { geometry in
                HStack(spacing: 12) {
                    
                    ZStack {
                        
                        Color.gray
                        
                        if let image = viewModel.image() {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.height,
                                       height: geometry.size.height,
                                       alignment: .topLeading)
                                .clipped()
                        }
                        
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(ContainerRelativeShape())
                    
                    VStack(alignment: .leading) {
                        if let topic = viewModel.topic {
                            Text(topic)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(viewModel.headline)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineSpacing(-8)
                    }
                }
            })
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ContainerRelativeShape()
                        .fill(Color("TextBackground"))
                        .opacity(colorScheme == .light ? 0.8 : 0.65))
    }
}
