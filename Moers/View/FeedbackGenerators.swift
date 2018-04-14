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
        
        if #available(iOS 10, *) {
            anyObject = UISelectionFeedbackGenerator()
        } else {
            anyObject = nil
        }
        
    }
    
    func prepare() {
        
        if #available(iOS 10, *) {
            (anyObject as! UISelectionFeedbackGenerator).prepare()
        }
        
    }
    
    func selectionChanged() {
        
        if #available(iOS 10, *) {
            (anyObject as! UISelectionFeedbackGenerator).selectionChanged()
        }
        
    }
    
}

class SuccessFeedbackGenerator {
    
    private let anyObject: AnyObject?
    
    init() {
        
        if #available(iOS 10, *) {
            anyObject = UINotificationFeedbackGenerator()
        } else {
            anyObject = nil
        }
        
    }
    
    func prepare() {
        
        if #available(iOS 10, *) {
            (anyObject as! UINotificationFeedbackGenerator).prepare()
        }
        
    }
    
    func success() {
        
        if #available(iOS 10, *) {
            (anyObject as! UINotificationFeedbackGenerator).notificationOccurred(.success)
        }
        
    }
    
}
