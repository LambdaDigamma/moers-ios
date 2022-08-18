//
//  LFSearchViewDataSource.swift
//  Moers
//
//  Created by Lennart Fischer on 17.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

public protocol LFSearchViewDataSource {
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    
    func statusBarStyle() -> UIStatusBarStyle
    
}

public extension LFSearchViewDataSource {
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: searchView.cellIdentifier)
        
        return cell!
        
    }
    
    func searchView(_ searchView: LFSearchViewController,tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func statusBarStyle() -> UIStatusBarStyle { return .default }
    
}
