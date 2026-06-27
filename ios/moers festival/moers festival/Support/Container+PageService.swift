//
//  Container+PageService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import FactoryKit
import Core
import MMPages

public extension Container {

    @MainActor
    var pageService: Factory<PageService> {
        self {
            DefaultPageService(client: Container.shared.httpClient())
        }
    }

}
