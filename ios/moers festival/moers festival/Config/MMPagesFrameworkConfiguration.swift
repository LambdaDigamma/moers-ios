//
//  MMPagesFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import ModernNetworking
import Cache
import Core
import MMPages
import FactoryKit

class MMPagesFrameworkConfiguration: BootstrappingProcedureStep {

    func execute(with application: UIApplication) {

        Container.shared.pageService.register {
            let client = Container.shared.httpClient.resolve()
            return DefaultPageService(client: client) as PageService
        }

        Container.shared.pageRepository.scope(.cached).register {
            let appDatabase = Container.shared.appDatabase.resolve()
            let client = Container.shared.httpClient.resolve()
            let service = DefaultPageService(client: client)
            let store = PageStore(
                writer: appDatabase.dbWriter,
                reader: appDatabase.reader
            )

            return PageRepository(service: service, store: store)
        }

    }

}
