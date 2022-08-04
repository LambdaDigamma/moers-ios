//
//  FluidNewsListItem.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 17.03.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI
//import NewsWidgets
import WidgetKit

public struct FluidNewsListItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    public let viewModel: NewsViewModel
    
    public var body: some View {
        Link(destination: viewModel.link, label: {
            GeometryReader(content: { geometry in
                HStack(spacing: 12) {
                    image(for: viewModel, with: geometry)
                    text(for: viewModel)
                }
            })
        })
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func image(for viewModel: NewsViewModel, with geometry: GeometryProxy) -> some View {
        
        ZStack {
            
            Color(UIColor.secondarySystemBackground)
            
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
        
    }
    
    @ViewBuilder
    private func text(for viewModel: NewsViewModel) -> some View {
        VStack(alignment: .leading) {
            if let topic = viewModel.topic {
                Text(topic)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(viewModel.headline)
                .foregroundColor(Color.primary)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineSpacing(-8)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.trailing, 8)
    }
    
    public static let fluidNewsWidget: CGFloat = 40
    
}

struct FluidNewsListItem_Previews: PreviewProvider {
    static var previews: some View {
        FluidNewsListItem(viewModel: NewsViewModel.mocked[0])
            .frame(height: 60)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
