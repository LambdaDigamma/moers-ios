//
//  MMPagesFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
@preconcurrency import ModernNetworking
import Cache
import MMPages
 import Factory

class MMPagesFrameworkConfiguration: BootstrappingProcedureStep {

    func execute(with application: UIApplication) {

        Container.shared.pageService.register {
            let loader = Container.shared.httpLoader.resolve()
            return DefaultPageService(loader) as PageService
        }

        Container.shared.pageRepository.scope(.cached).register {
            let appDatabase = Container.shared.appDatabase.resolve()
            let loader = Container.shared.httpLoader.resolve()
            let service = DefaultPageService(loader)
            let store = PageStore(
                writer: appDatabase.dbWriter,
                reader: appDatabase.reader
            )

            return PageRepository(service: service, store: store)
        }

    }

}
