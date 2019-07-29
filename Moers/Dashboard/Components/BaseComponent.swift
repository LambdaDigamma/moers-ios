//
//  BaseComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 27.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class BaseComponent: NSObject {
    
    public var view: UIView!
    public weak var viewController: UIViewController?
    
    public init(viewController: UIViewController) {
        
        self.viewController = viewController
        
    }
    
    public func register(view: UIView) {
        self.view = view
    }
    
    public func update() {
        
    }
    
    public func refresh() {
        
    }
    
    public func invalidate() {
        
    }
    
}
