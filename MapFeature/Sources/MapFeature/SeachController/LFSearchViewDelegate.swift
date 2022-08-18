//
//  LFSearchViewDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 17.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

public protocol LFSearchViewDelegate: AnyObject {
    
    func searchView(_ searchView: LFSearchViewController, didTextChangeTo text: String, textLength: Int)
    
    func searchView(_ searchView: LFSearchViewController, didSearchForText text: String)
    
    func searchView(_ searchView: LFSearchViewController, didSelectResultAt index: Int)
    
    func searchView(_ searchView: LFSearchViewController, didDismissWithText text: String)
    
    func searchView(_ searchView: LFSearchViewController, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
}

public extension LFSearchViewDelegate {
    
    func searchView(_ searchView: LFSearchViewController, didDismissWithText text: String) {
        
    }
    
    func searchView(_ searchView: LFSearchViewController, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LFSearchViewDefaults.cellHeight
    }
    
}
