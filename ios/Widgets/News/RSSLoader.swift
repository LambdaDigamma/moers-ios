//
//  RSSLoader.swift
//  Moers
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import FeedKit
import UIKit

public class RSSLoader: NewsLoader {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchEntry() async throws -> NewsEntry {
        let items = try await fetchRSSFeedItems()

        var viewModels: [NewsViewModel] = []

        for item in items.prefix(4) {
            var imageURL: URL?
            if let enclosure = item.enclosure?.attributes?.url {
                imageURL = URL(string: enclosure)
            }

            var viewModel = NewsViewModel(
                topic: nil,
                headline: item.title ?? "",
                link: URL(string: item.link ?? "https://tagesschau.de")!,
                imageURL: imageURL
            )

            if let url = imageURL {
                let image = await loadImage(from: url)
                viewModel.image = { image }
            }

            viewModels.append(viewModel)
        }

        return NewsEntry(viewModels: viewModels, date: Date())
    }

    private func loadImage(from url: URL) async -> UIImage {
        do {
            let (data, _) = try await session.data(from: url)
            return UIImage(data: data) ?? UIImage()
        } catch {
            return UIImage()
        }
    }

    private func fetchRSSFeedItems() async throws -> [RSSFeedItem] {
        let feedURL = URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss")!
        let feed = try await Feed(url: feedURL)
        return feed.rss?.channel?.items ?? []
    }

}
