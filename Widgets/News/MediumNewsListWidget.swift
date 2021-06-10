//
//  MediumNewsListWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import NewsWidgets

struct MediumNewsListWidget: View {
    
    let news: [NewsViewModel]
    
    init(news: [NewsViewModel] = NewsViewModel.mocked) {
        self.news = Array(news.prefix(2))
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                ForEach(0..<self.news.count) { i in
                    InsetNewsListItem(viewModel: news[i])
                }
                
            }
            .padding(8)
            .background(Color("WidgetBackground"))
            
        }
    }
    
}

struct MediumListNewsWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumNewsListWidget()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        MediumNewsListWidget()
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
