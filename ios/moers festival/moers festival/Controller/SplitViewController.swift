//
//  SplitViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.12.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .tile
        
        super.delegate = self
    }

}

@available(iOS 14.0, *)
extension SplitViewController: UISplitViewControllerDelegate {
    
    
    
}
