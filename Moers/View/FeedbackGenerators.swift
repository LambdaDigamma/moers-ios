//
//  FeedbackGenerators.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class SelectionFeedbackGenerator {
    
    private let anyObject: AnyObject?
    
    init() {
        
        anyObject = UISelectionFeedbackGenerator()
        
    }
    
    func prepare() {
        
        (anyObject as! UISelectionFeedbackGenerator).prepare()
        
    }
    
    func selectionChanged() {
        
        (anyObject as! UISelectionFeedbackGenerator).selectionChanged()
        
    }
    
}

class SuccessFeedbackGenerator {
    
    private let anyObject: AnyObject?
    
    init() {
        
        anyObject = UINotificationFeedbackGenerator()
        
    }
    
    func prepare() {
        
        (anyObject as! UINotificationFeedbackGenerator).prepare()
        
    }
    
    func success() {
        
        (anyObject as! UINotificationFeedbackGenerator).notificationOccurred(.success)
        
    }
    
}
