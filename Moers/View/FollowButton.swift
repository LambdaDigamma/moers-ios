//
//  FollowButton.swift
//  Moers
//
//  Created by Lennart Fischer on 24.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class FollowButton: UIButton {

    override var tintColor: UIColor! {
        didSet {
            
            if isFilled {
                self.layer.borderColor = tintColor.cgColor
                self.setTitleColor(UIColor.black, for: .normal)
            } else {
                self.layer.borderColor = tintColor.cgColor
                self.setTitleColor(tintColor, for: .normal)
            }
            
        }
    }
    
    var isFilled = false {
        didSet {
            if isFilled {
                self.setBackgroundColor(color: tintColor, forState: .normal)
                self.setTitleColor(UIColor.black, for: .normal)
            } else {
                self.setBackgroundColor(color: UIColor.clear, forState: .normal)
                self.setTitleColor(tintColor, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
