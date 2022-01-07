//
//  SplitController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit

public class SplitController: UISplitViewController {
    
    init(tabController: TabBarController) {
        super.init(style: .doubleColumn)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
