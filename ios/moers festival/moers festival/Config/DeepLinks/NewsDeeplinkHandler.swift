//
//  NewsDeeplinkHandler.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit

final class NewsDeeplinkHandler: DeeplinkHandlerProtocol {
    
    private weak var rootViewController: ApplicationController?
    
    init(rootViewController: ApplicationController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix("moersfestival://posts")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        var pathComponents = url.pathComponents
        pathComponents.removeFirst()
        
        if let firstPath = pathComponents.first, firstPath.isNotEmptyOrWhitespace {
            
            let postID = Int(firstPath)
            
            if let postID {
                rootViewController?.openPostDetail(postID: postID)
                return
            }
            
        }
        
        rootViewController?.openNews()
        
    }
}
