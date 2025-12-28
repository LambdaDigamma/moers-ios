//
//  OtherDataSource.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class OtherDataSource: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    
    private let viewModel: OtherViewModel
    
    public init(viewModel: OtherViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as UITableViewCell
        
        cell.backgroundColor = UIColor.systemBackground
        cell.textLabel?.textColor = UIColor.label
        
        cell.textLabel?.text = viewModel.title(for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.header(for: section)
    }
    
}
