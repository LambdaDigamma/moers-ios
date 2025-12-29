//
//  Container+PageService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import Factory
import MMPages

public extension Container {

    var pageService: Factory<PageService> {
        self {
            DefaultPageService(Container.shared.httpLoader())
        }
    }

}
