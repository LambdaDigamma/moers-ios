//
//  EventViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 09.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MMPages
import MMEvents
import UIKit
import Factory

public class EventViewController: DefaultHostingController {
    
    @LazyInjected(\.legacyEventService) var eventService
    @LazyInjected(\.pageService) var pageService
    
    public var eventID: Event.ID? {
        didSet {
            self.load()
        }
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    // MARK: - Data -
    
    private func load() {
        
        guard let eventID = eventID else {
            return
        }

        Task { [weak self] in
            guard let self else { return }
            
            do {
                let event = try await self.eventService.show(eventID: eventID)
                guard let pageID = event.pageID else { return }
                
                await MainActor.run {
                    let pageViewController = PageViewController(pageID: pageID, pageService: self.pageService)
                    
                    pageViewController.config = .init(showShare: true, showLike: true)
//                    pageViewController.config.likeState = {
//                        return viewModel.isLiked
//                    }
//                    pageViewController.config.toggleLike = {
//                        return viewModel.toggleLike()
//                    }
                    
                    self.navigationController?.pushViewController(pageViewController, animated: true)
                    
                    print(event)
                }
            } catch {
                print(error)
            }
        }
            
    }
    
    
}
