//
//  NewsWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import NewsWidgets

struct NewsWidgets: Widget {
    
    let kind: String = "Widgets"
    let provider: NewsTimelineProvider
    
    init() {
        let loader = RSSLoader()
        provider = NewsTimelineProvider(loader: loader)
    }
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: provider) { entry in
            NewsWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetStrings.News.widgetTitle)
        .description(WidgetStrings.News.widgetDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
    
}

struct NewsWidgetView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: NewsEntry
    
    var body: some View {
        
        switch widgetFamily {
            case .systemSmall:
                if let viewModel = entry.viewModels.first {
                    SmallNewsImageWidget(viewModel: viewModel)
                } else {
                    Color("WidgetBackground")
                }
                
            case .systemMedium:
                MediumNewsListWidget(news: entry.viewModels)
            case .systemLarge:
                BigNewsTilesWidget(viewModels: entry.viewModels)
            
            default:
                fatalError("This widget size is not supported")
        }
        
    }
    
}
