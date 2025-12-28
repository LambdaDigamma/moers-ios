//
//  MMPagesFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import Resolver
import ModernNetworking
import Cache
import MMPages
import Factory

class MMPagesFrameworkConfiguration: BootstrappingProcedureStep {
    
    private var loader: HTTPLoader!
    
    public init() {
        
    }
    
    func execute(with application: UIApplication) {
        
        self.loader = Container.shared.httpLoader.resolve()
        
        let service = DefaultPageService(loader)
        let store = PageStore(
            writer: Container.shared.appDatabase.resolve().dbWriter,
            reader: Container.shared.appDatabase.resolve().reader
        )
        
        Resolver.register { service as PageService }
        
        Container.shared.pageRepository.scope(.cached).register {
            PageRepository(service: service, store: store)
        }
        
    }
    
//    private func createMockedFeedService() -> MockFeedService {
//
//        let mockedPosts = [
//            Post.stub(withID: 1)
//                .setting(\.title, to: "Post1Title".localized(in: "MockData"))
//                .setting(\.summary, to: "Post1Summary".localized(in: "MockData")),
//            Post.stub(withID: 2)
//                .setting(\.title, to: "Post2Title".localized(in: "MockData"))
//                .setting(\.summary, to: "Post2Summary".localized(in: "MockData")),
//            Post.stub(withID: 3)
//                .setting(\.title, to: "Post3Title".localized(in: "MockData"))
//                .setting(\.summary, to: "Post3Summary".localized(in: "MockData"))
//        ]
//
//        return MockFeedService(posts: mockedPosts)
//
//    }
    
}
