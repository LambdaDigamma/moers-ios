//
//  MediumNewsListWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
//import NewsWidgets

struct MediumNewsListWidget: View {
    
    let news: [NewsViewModel]
    
    init(news: [NewsViewModel] = NewsViewModel.mocked) {
        self.news = Array(news.prefix(2))
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                ForEach(self.news) { newsItem in
                    FluidNewsListItem(viewModel: newsItem)
                }
                
            }
            .padding(12)
            
        }
        .background(Color(UIColor.systemBackground))
        
    }
    
}

struct MediumListNewsWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumNewsListWidget()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        MediumNewsListWidget()
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
    }
}
