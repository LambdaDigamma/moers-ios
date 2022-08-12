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
        guard let feedbackGenerator = anyObject as? UISelectionFeedbackGenerator else { return }
        feedbackGenerator.prepare()
    }
    
    func selectionChanged() {
        guard let feedbackGenerator = anyObject as? UISelectionFeedbackGenerator else { return }
        feedbackGenerator.selectionChanged()
    }
    
}

class SuccessFeedbackGenerator {
    
    private let anyObject: AnyObject?
    
    init() {
        anyObject = UINotificationFeedbackGenerator()
    }
    
    func prepare() {
        guard let feedbackGenerator = anyObject as? UINotificationFeedbackGenerator else { return }
        feedbackGenerator.prepare()
    }
    
    func success() {
        guard let feedbackGenerator = anyObject as? UINotificationFeedbackGenerator else { return }
        feedbackGenerator.notificationOccurred(.success)
    }
    
}
