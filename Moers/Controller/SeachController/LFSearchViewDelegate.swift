//
//  LFSearchViewDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 17.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

public protocol LFSearchViewDelegate {
    
    func searchView(_ searchView: LFSearchViewController, didTextChangeTo text: String, textLength: Int)
    
    func searchView(_ searchView: LFSearchViewController, didSearchForText text: String)
    
    func searchView(_ searchView: LFSearchViewController, didSelectResultAt index: Int)
    
    func searchView(_ searchView: LFSearchViewController, didDismissWithText text: String)
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]?
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
}

public extension LFSearchViewDelegate {
    
    func searchView(_ searchView: LFSearchViewController, didDismissWithText text: String) {
        
    }
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        return []
    }
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LFSearchViewDefaults.cellHeight
    }
    
}
