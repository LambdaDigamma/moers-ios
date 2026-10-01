//
//  AccessibleBulletinItem.swift
//  Moers
//
//  Created by Lennart Fischer on 13.02.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard

class AccessibleBulletinPageItem: BLTNPageItem {
    
    public var titleLabelAccessibilityIdentifier: String = ""
    public var actionButtonAccessibilityIdentifier: String = ""
    public var alternativeButtonAccessibilityIdentifier: String = ""
    
    override init(title: String) {
        super.init(title: title)
        
        self.setupPresentationHandler()
        
    }
    
    private func setupPresentationHandler() {
        
        self.presentationHandler = { item in
            guard let item = item as? AccessibleBulletinPageItem else { return }
            
            item.actionButton?.accessibilityIdentifier = item.actionButtonAccessibilityIdentifier
            item.alternativeButton?.accessibilityIdentifier = item.alternativeButtonAccessibilityIdentifier
            item.titleLabel?.label.accessibilityIdentifier = item.titleLabelAccessibilityIdentifier
            
        }
        
    }
    
}
