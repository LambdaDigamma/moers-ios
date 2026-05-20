//
//  DeeplinkCoordinatorProtocolSpy.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import Foundation
@testable import moers_festival

@MainActor
final class DeeplinkCoordinatorProtocolSpy: DeeplinkCoordinatorProtocol {
    private let urlsToHandle: Set<URL>
    private(set) var handledURLs: [URL] = []

    init(urlsToHandle: Set<URL> = []) {
        self.urlsToHandle = urlsToHandle
    }

    func handleURL(_ url: URL) -> Bool {
        handledURLs.append(url)
        return urlsToHandle.contains(url)
    }
}
