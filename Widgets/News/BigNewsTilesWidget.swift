//
//  BigNewsTilesWidget.swift
//  Watch Extension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import NewsWidgets

struct BigNewsTilesWidget: View {
    
    public let viewModels: [NewsViewModel]
    
    public init(viewModels: [NewsViewModel] = []) {
        self.viewModels = viewModels
    }
    
    var body: some View {
        ZStack {
            
            Color("WidgetBackground")
            
            VStack {
                
                ForEach(0..<2) { row in
                    HStack {
                        ForEach(0..<2) { col in
                            
                            let viewModel: NewsViewModel? = viewModels[safe: row * 2 + col]
                            
                            if let viewModel = viewModel {
                                Link(destination: viewModel.link, label: {
                                    ZStack(alignment: .bottom) {
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
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            if let topic = viewModel.topic {
                                                Text(topic)
                                                    .font(Font.system(size: 11))
                                                    .foregroundColor(Color.white)
                                                    .environment(\.colorScheme, .dark)
                                            }
                                            Text(viewModel.headline)
                                                .font(Font.system(size: 13))
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .padding(.top, 80)
                                        .padding(.bottom, 8)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6), Color.black]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                })
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(ContainerRelativeShape())
                                .background(ContainerRelativeShape()
                                                .fill(Color("TextBackground"))
                                                .opacity(0.95))
                                .compositingGroup()
                                .shadow(radius: 2)
                                .environment(\.colorScheme, .dark)
                            } else {
                                Spacer()
                            }
                            
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
//            .background(TagesschauBackground(alternative: true).overlay(Color.black.opacity(0.3)))
            
        }
    }
    
}

struct BigNewsTilesWidget_Previews: PreviewProvider {
    static var previews: some View {
        BigNewsTilesWidget(viewModels: NewsViewModel.mocked)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
