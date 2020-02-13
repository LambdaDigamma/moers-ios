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
    
    override init() {
        super.init()
        
        self.setupPresentationHandler()
        
    }
    
    private func setupPresentationHandler() {
        
        self.presentationHandler = { item in
            let item = item as? AccessibleBulletinPageItem
            
            item?.actionButton?.accessibilityIdentifier = self.actionButtonAccessibilityIdentifier
            item?.alternativeButton?.accessibilityIdentifier = self.alternativeButtonAccessibilityIdentifier
            item?.titleLabel.label.accessibilityIdentifier = self.titleLabelAccessibilityIdentifier
            
        }
        
    }
    
}
