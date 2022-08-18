//
//  BigNewsTilesWidget.swift
//  Watch Extension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
//import NewsWidgets

public struct BigNewsTilesWidget: View {
    
    @Environment(\.redactionReasons) var reasons
    
    public let viewModels: [NewsViewModel]
    
    public init(viewModels: [NewsViewModel] = []) {
        self.viewModels = viewModels
    }
    
    public var body: some View {
        ZStack {
            VStack {
                ForEach(0..<2) { row in
                    HStack {
                        ForEach(0..<2) { col in
                            
                            let viewModel: NewsViewModel? = viewModels[safe: row * 2 + col]
                            
                            if let viewModel = viewModel {
                                
                                Link(destination: viewModel.link, label: {
                                    ZStack(alignment: .bottom) {
                                        backgroundImage(for: viewModel)
                                        textWithBackdrop(for: viewModel)
                                    }
                                })
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.secondarySystemBackground).opacity(0.4))
                                .clipShape(ContainerRelativeShape())
                                .compositingGroup()
                                .shadow(radius: 2)
                            } else {
                                Spacer()
                            }
                            
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .background(Color(UIColor.systemBackground))
            
        }
    }
    
    @ViewBuilder
    private func backgroundImage(for viewModel: NewsViewModel) -> some View {
        GeometryReader(content: { geometry in
            if let image = viewModel.image() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.height,
                           height: geometry.size.height,
                           alignment: .topLeading)
                    .clipped()
            }
        })
    }
    
    @ViewBuilder
    private func textWithBackdrop(for viewModel: NewsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let topic = viewModel.topic {
                Text(topic)
                    .font(Font.system(size: 11))
                    .foregroundColor(currentTextColor)
                    .environment(\.colorScheme, .dark)
            }
            Text(viewModel.headline)
                .font(Font.system(size: 13))
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .foregroundColor(currentTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .padding(.top, 80)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: reasons.isEmpty ? [
                    Color.clear,
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.85)
                ] : [
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var currentTextColor: Color {
        if !reasons.isEmpty {
            return Color.primary
        }
        return Color.white
    }
    
}

struct BigNewsTilesWidget_Previews: PreviewProvider {
    static var previews: some View {
        BigNewsTilesWidget(viewModels: NewsViewModel.mocked)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        
        BigNewsTilesWidget(viewModels: NewsViewModel.mocked)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .preferredColorScheme(.dark)
    }
}
