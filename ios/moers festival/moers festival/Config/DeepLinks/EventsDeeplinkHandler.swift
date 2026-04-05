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
        return url.scheme == "moersfestival"
            && normalizedComponents(for: url).first == "events"
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        let pathComponents = normalizedComponents(for: url)
        
        if let firstPath = pathComponents.dropFirst().first, firstPath.isNotEmptyOrWhitespace {
            
            let eventID = Int(firstPath)
            
            if let eventID {
                rootViewController?.openEventDetail(eventID: eventID)
                return
            }
            
        }
        
        rootViewController?.openEvents()
        
    }
    
    private func normalizedComponents(for url: URL) -> [String] {
        var components: [String] = []
        
        if let host = url.host, host.isNotEmptyOrWhitespace {
            components.append(host)
        }
        
        components.append(contentsOf: url.pathComponents.filter { $0 != "/" })
        
        return components
    }
}
