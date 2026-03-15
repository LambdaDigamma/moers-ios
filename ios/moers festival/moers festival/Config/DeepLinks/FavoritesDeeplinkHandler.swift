//
//  FavoritesDeeplinkHandler.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit

final class FavoritesDeeplinkHandler: DeeplinkHandlerProtocol {
    
    private weak var rootViewController: ApplicationController?
    
    init(rootViewController: ApplicationController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix("moersfestival://favorites")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        rootViewController?.openUserSchedule()
        
    }
}
