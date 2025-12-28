//
//  EventsDeeplinkHandler.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit

final class EventsDeeplinkHandler: DeeplinkHandlerProtocol {
    
    private weak var rootViewController: ApplicationController?
    
    init(rootViewController: ApplicationController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix("moersfestival://events")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        var pathComponents = url.pathComponents
        pathComponents.removeFirst()
        
        if let firstPath = pathComponents.first, firstPath.isNotEmptyOrWhitespace {
            
            let eventID = Int(firstPath)
            
            if let eventID {
                rootViewController?.openEventDetail(eventID: eventID)
                return
            }
            
        }
        
        rootViewController?.openEvents()
        
    }
}
