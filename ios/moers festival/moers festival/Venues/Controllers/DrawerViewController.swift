//
//  DrawerViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import Pulley
import MMEvents

class DrawerViewController: UIViewController {

    public weak var coordinator: moers_festival.MapCoordinator?
    
    // MARK: - UI
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var gripperView: UIView!
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var bottomSeparatorView: UIView!
    
    public lazy var drawer = {
        self.parent as! MapCoordinatorViewController
    }()
    
    public var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    // MARK: - Data
    
    public var mappables: [Mappable] = []
    
    public var trackers: [Tracker] = []
    public var entries: [Entry] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        
        self.gripperView.layer.cornerRadius = 2.5
        self.topSeparatorView.alpha = 0.75
        
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.barStyle = .default
        self.searchBar.isTranslucent = true
        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.placeholder = String.localized("SearchBarPrompt")
        self.searchBar.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 70
        self.tableView.register(DrawerItemTableViewCell.self, forCellReuseIdentifier: DrawerItemTableViewCell.identifier)
        self.tableView.register(HintTableViewCell.self)
        
    }
    
    private func setupTheming() {
        
        self.bottomSeparatorView.backgroundColor = UIColor.clear
        self.gripperView.backgroundColor = UIColor.secondarySystemFill
        self.topSeparatorView.backgroundColor = UIColor.secondarySystemFill
        self.view.backgroundColor = UIColor.systemBackground
        self.searchBar.barTintColor = AppColors.navigationAccent
        self.searchBar.backgroundColor = UIColor.systemBackground
        self.searchBar.tintColor = AppColors.navigationAccent
        self.searchBar.textField?.textColor = UIColor.label
        self.topSeparatorView.backgroundColor = UIColor.separator
        self.tableView.backgroundColor = UIColor.systemBackground
        self.tableView.separatorColor = UIColor.separator
        
    }
    
}

extension DrawerViewController: TrackerDatasource {
    
    func didReceiveTrackers(_ trackers: [Tracker]) {
        
        self.trackers = trackers
        self.mappables.removeAll(where: { $0 is Tracker })
        self.mappables.append(contentsOf: trackers)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}

extension DrawerViewController: LocationDatasource {
    
    func didReceiveLocations(_ locations: [Entry]) {
        
        self.entries = locations.sorted(by: { (e1, e2) -> Bool in
            e1.name < e2.name
        })
        
        self.mappables.removeAll(where: { $0 is Entry })
        self.mappables.append(contentsOf: entries)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}

extension DrawerViewController: UISearchBarDelegate {
    
    
    
}
