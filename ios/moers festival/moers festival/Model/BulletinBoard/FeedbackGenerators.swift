//
//  FeedbackGenerators.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class SelectionFeedbackGenerator {
    
    private let feedbackGenerator: UISelectionFeedbackGenerator
    
    init() {
        
        feedbackGenerator = UISelectionFeedbackGenerator()
        
    }
    
    func prepare() {
        
        feedbackGenerator.prepare()
        
    }
    
    func selectionChanged() {
        
        feedbackGenerator.selectionChanged()
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

class SuccessFeedbackGenerator {
    
    private let feedbackGenerator: UINotificationFeedbackGenerator
    
    init() {
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        
    }
    
    func prepare() {
        
        feedbackGenerator.prepare()
        
    }
    
    func success() {
        
        feedbackGenerator.notificationOccurred(.success)
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
