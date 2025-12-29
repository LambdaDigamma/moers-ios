//
//  MMFeedsFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import ModernNetworking
import Cache
import MMFeeds
import Factory

class MMFeedsFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        let loader = Container.shared.httpLoader.resolve()
        
        do {
            
            if LaunchArgumentsHandler.shouldUseMockedFeed {
                
                let mockedFeedService = createMockedFeedService()
                
                Container.shared.feedService.register {
                    mockedFeedService
                }
                
                return
            }
            
            let cache = try Storage<String, Feed>(
                diskConfig: DiskConfig(name: "FeedService"),
                memoryConfig: MemoryConfig(),
                transformer: TransformerFactory.forCodable(ofType: Feed.self))
            
            let service = DefaultFeedService(loader, cache)
            
            Container.shared.feedService.register {
                service as FeedService
            }
            
        } catch {
            
            print("Failed to create event cache.")
            print(error.localizedDescription)
            
        }
        
        let service = DefaultPostService(loader)
        let store = PostStore(
            writer: Container.shared.appDatabase.resolve().dbWriter,
            reader: Container.shared.appDatabase.resolve().reader
        )
        
        Container.shared.postRepository.scope(.cached).register {
            PostRepository(service: service, store: store)
        }
        
    }
    
    private func createMockedFeedService() -> MockFeedService {
        
        let mockedPosts = [
            Post.stub(withID: 1)
                .setting(\.title, to: "Post1Title".localized(in: "MockData"))
                .setting(\.summary, to: "Post1Summary".localized(in: "MockData")),
            Post.stub(withID: 2)
                .setting(\.title, to: "Post2Title".localized(in: "MockData"))
                .setting(\.summary, to: "Post2Summary".localized(in: "MockData")),
            Post.stub(withID: 3)
                .setting(\.title, to: "Post3Title".localized(in: "MockData"))
                .setting(\.summary, to: "Post3Summary".localized(in: "MockData"))
        ]
        
        return MockFeedService(posts: mockedPosts)
        
    }
    
}
