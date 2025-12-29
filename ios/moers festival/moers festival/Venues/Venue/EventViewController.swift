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
import Combine
import Factory

public class EventViewController: DefaultHostingController {
    
    @LazyInjected(\.legacyEventService) var eventService
    @LazyInjected(\.pageService) var pageService
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        eventService.show(eventID: eventID)
            .sink { (completion: Subscribers.Completion<Error>) in
                print(completion)
            } receiveValue: { (event: Event) in
                
                guard let pageID = event.pageID else { return }
                
                let pageViewController = PageViewController(pageID: pageID, pageService: self.pageService)
                
                pageViewController.config = .init(showShare: true, showLike: true)
//                pageViewController.config.likeState = {
//                    return viewModel.isLiked
//                }
//                pageViewController.config.toggleLike = {
//                    return viewModel.toggleLike()
//                }
                
                self.navigationController?.pushViewController(pageViewController, animated: true)
                
                
                
                print(event)
            }
            .store(in: &cancellables)
            
    }
    
    
}
