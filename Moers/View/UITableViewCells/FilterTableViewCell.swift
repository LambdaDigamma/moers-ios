//
//  FilterTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 05.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var branchLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var onButtonClick: ((UITableViewCell) -> Void)?
    
    @IBAction func close(_ sender: UIButton) {
        
        onButtonClick?(self)
        
    }
    
}
