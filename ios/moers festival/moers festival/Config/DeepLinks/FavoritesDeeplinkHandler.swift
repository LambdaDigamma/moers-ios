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
        return url.scheme == "moersfestival"
            && normalizedComponents(for: url).first == "favorites"
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        rootViewController?.openUserSchedule()
        
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
