//
//  NewsTimelineProvider.swift
//
//
//  Created by Lennart Fischer on 10.06.21.
//

import WidgetKit
import SwiftUI

public final class NewsTimelineProvider: TimelineProvider {

    private let loader: NewsLoader

    public init(loader: NewsLoader) {
        self.loader = loader
    }

    public func placeholder(in context: Context) -> NewsEntry {
        return NewsEntry(viewModels: NewsViewModel.mocked)
    }

    public func getSnapshot(in context: Context, completion: @escaping (NewsEntry) -> ()) {
        Task {
            let entry = (try? await loader.fetchEntry()) ?? NewsEntry(viewModels: [])
            completion(entry)
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<NewsEntry>) -> Void) {
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!

        Task {
            let entry = (try? await loader.fetchEntry()) ?? NewsEntry(viewModels: [])
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }

}
