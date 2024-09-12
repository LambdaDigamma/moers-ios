//
//  ImageNewsView.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
//import NewsWidgets

struct ImageNewsView: View {
    
    var viewModel: NewsViewModel
    
    var body: some View {
        Link(destination: viewModel.link, label: {
            ZStack(alignment: .bottom) {
                GeometryReader(content: { geometry in
                    if let image = viewModel.image() {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height,
                                alignment: .topLeading
                            )
                            .clipped()
                    }
                })
                
                VStack(alignment: .leading, spacing: 4) {
                    if let topic = viewModel.topic {
                        Text(topic)
                            .font(Font.system(size: 9))
                            .foregroundColor(Color.white)
                            .environment(\.colorScheme, .dark)
                    }
                    Text(viewModel.headline)
                        .font(Font.system(size: 12))
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
                        gradient: Gradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.6),
                                Color.black.opacity(0.85)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(ContainerRelativeShape())
        .background(Color("WidgetBackground"))
        .compositingGroup()
        .shadow(radius: 1)
        .environment(\.colorScheme, .dark)
    }
    
}

struct ImageNewsView_Previews: PreviewProvider {
    static var previews: some View {
        ImageNewsView(viewModel: NewsViewModel.mocked[0])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
