//
//  NewsTimelineProvider.swift
//  
//
//  Created by Lennart Fischer on 10.06.21.
//

import WidgetKit
import SwiftUI
import Combine

public final class NewsTimelineProvider: TimelineProvider {
    
    private let loader: NewsLoader
    
    public init(loader: NewsLoader) {
        self.loader = loader
        
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    public func placeholder(in context: Context) -> NewsEntry {
        return NewsEntry(viewModels: NewsViewModel.mocked)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (NewsEntry) -> ()) {
        
        loader.fetchEntry()
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { entry in
                let entry = NewsEntry(viewModels: entry.viewModels)
                completion(entry)
            })
            .store(in: &cancellables)
        
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<NewsEntry>) -> Void) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        loader.fetchEntry()
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { entry in
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                
                completion(timeline)
            })
            .store(in: &cancellables)
        
    }
    
}
