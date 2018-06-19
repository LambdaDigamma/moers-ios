//
//  FeedbackPageBulletinItem.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard

class FeedbackPageBulletinItem: BLTNPageItem {
    
    private let feedbackGenerator = SelectionFeedbackGenerator()
    
    override func actionButtonTapped(sender: UIButton) {
        
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        
        super.actionButtonTapped(sender: sender)
        
    }
    
    override func alternativeButtonTapped(sender: UIButton) {
        
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        
        super.alternativeButtonTapped(sender: sender)
        
    }
    
}
