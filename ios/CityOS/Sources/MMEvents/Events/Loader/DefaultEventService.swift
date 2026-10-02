//
//  DefaultEventService.swift
//
//
//  Created by Lennart Fischer on 12.04.23.
//

import Foundation
import Core
import ModernNetworking

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

        var request = HTTPRequest(path: withPages ? Endpoint.downloadContent.path() : Endpoint.index.path())

        request.cachePolicy = cacheMode.policy

        if withPages {
            let result = await client.load(request)
            let events = try await result.decoding(EventResourceCollection.self, using: Event.decoder)

            return events.resourceCollection
        }

        let firstPage = try await loadIndexPage(cacheMode: cacheMode, pageNumber: 1)
        let lastPage = max(firstPage.meta.lastPage ?? 1, 1)

        guard lastPage > 1 else {
            return firstPage.resourceCollection
        }

        var data = firstPage.data

        for pageNumber in 2...lastPage {
            let page = try await loadIndexPage(cacheMode: cacheMode, pageNumber: pageNumber)
            data.append(contentsOf: page.data)
        }

        return EventResourceCollection(
            data: data,
            links: firstPage.links,
            meta: firstPage.meta
        ).resourceCollection

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
