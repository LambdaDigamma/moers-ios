//
//  DefaultEventService.swift
//
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import Core
import ModernNetworking

@MainActor
public class DefaultEventService: EventService {

    private let client: any HTTPClient

    public init(client: any HTTPClient) {
        self.client = client
    }

    @MainActor
    public convenience init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.init(client: HTTPLoaderClient(loader: loader))
    }

    public func index(cacheMode: CacheMode, withPages: Bool = false) async throws -> ResourceCollection<Event> {
        try await loadIndex(cacheMode: cacheMode, withPages: withPages, onPage: nil)
    }

    public func index(
        cacheMode: CacheMode,
        withPages: Bool,
        onPage: @escaping @MainActor @Sendable ([Event]) -> Void
    ) async throws -> ResourceCollection<Event> {
        try await loadIndex(cacheMode: cacheMode, withPages: withPages, onPage: onPage)
    }

    private func loadIndex(
        cacheMode: CacheMode,
        withPages: Bool,
        onPage: (@MainActor @Sendable ([Event]) -> Void)?
    ) async throws -> ResourceCollection<Event> {

        if withPages {
            return try await loadContent(cacheMode: cacheMode, onPage: onPage)
        }

        let firstPage = try await loadIndexPage(cacheMode: cacheMode, pageNumber: 1)
        let lastPage = max(firstPage.meta.lastPage ?? 1, 1)
        try Task.checkCancellation()
        onPage?(Event.unique(firstPage.data))

        var pages = [1: firstPage.data]
        var failedPages: [Int] = []
        if lastPage > 1 {
            await withTaskGroup(of: (Int, [Event]?).self) { group in
                var nextPage = 2
                for _ in 0..<min(3, lastPage - 1) {
                    let number = nextPage
                    group.addTask {
                        await self.loadIndexPageResult(cacheMode: cacheMode, pageNumber: number)
                    }
                    nextPage += 1
                }
                while let (number, events) = await group.next() {
                    if Task.isCancelled {
                        group.cancelAll()
                        continue
                    }
                    if let events {
                        pages[number] = events
                        onPage?(Event.unique(pages.keys.sorted().flatMap { pages[$0] ?? [] }))
                    } else {
                        failedPages.append(number)
                    }
                    if nextPage <= lastPage {
                        let number = nextPage
                        group.addTask {
                            await self.loadIndexPageResult(cacheMode: cacheMode, pageNumber: number)
                        }
                        nextPage += 1
                    }
                }
            }
        }
        try Task.checkCancellation()
        let data = Event.unique(pages.keys.sorted().flatMap { pages[$0] ?? [] })
        // Repository callers replace stored rows only after a complete successful index.
        guard failedPages.isEmpty else {
            throw EventIndexLoadError(events: data, failedPages: failedPages.sorted())
        }

        return EventResourceCollection(
            data: data,
            links: firstPage.links,
            meta: firstPage.meta
        ).resourceCollection

    }

    private func loadContent(
        cacheMode: CacheMode,
        onPage: (@MainActor @Sendable ([Event]) -> Void)?
    ) async throws -> ResourceCollection<Event> {
        var request = HTTPRequest(path: Endpoint.downloadContent.path())
        request.cachePolicy = cacheMode.policy
        let result = await client.load(request)
        let events = try await result.decoding(EventResourceCollection.self, using: Event.decoder)
        try Task.checkCancellation()
        onPage?(events.data)
        return events.resourceCollection
    }

    private func loadIndexPageResult(cacheMode: CacheMode, pageNumber: Int) async -> (Int, [Event]?) {
        do {
            try Task.checkCancellation()
            let page = try await loadIndexPage(cacheMode: cacheMode, pageNumber: pageNumber)
            try Task.checkCancellation()
            return (pageNumber, page.data)
        } catch {
            return (pageNumber, nil)
        }
    }

    public func show(event eventID: Event.ID, cacheMode: CacheMode) async throws -> Resource<Event> {

        var request = HTTPRequest(path: Endpoint.show(event: eventID).path())

        request.cachePolicy = cacheMode.policy

        let result = await client.load(request)

        let events = try await result.decoding(EventResource.self, using: Event.decoder)

        return events.resource

    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

nonisolated extension DefaultEventService {

    public enum Endpoint {
        case index
        case show(event: Event.ID)
        case downloadContent

        func path() -> String {
            switch self {
                case .index:
                    return "events"
                case .show(let eventID):
                    return "events/\(eventID)"
                case .downloadContent:
                    return "content"
            }
        }
    }

    public enum CachingKeys: String {
        case events = "events"
    }

}

private extension DefaultEventService {

    static var indexPageSize: Int { 30 }

    func loadIndexPage(cacheMode: CacheMode, pageNumber: Int) async throws -> EventResourceCollection {
        var request = HTTPRequest(path: Endpoint.index.path())

        request.cachePolicy = cacheMode.policy
        request.queryItems = [
            URLQueryItem(name: "page[size]", value: String(Self.indexPageSize)),
            URLQueryItem(name: "page[number]", value: String(pageNumber)),
        ]

        let result = await client.load(request)

        return try await result.decoding(EventResourceCollection.self, using: Event.decoder)
    }

}
