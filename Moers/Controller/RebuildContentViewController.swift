//
//  RebuildContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Pulley
import Crashlytics

public enum SearchStyle {
    
    case none
    case branchSearch
    case textSearch
    
}

class RebuildContentViewController: UIViewController, PulleyDrawerViewControllerDelegate, UISearchBarDelegate {

    // MARK: - UI
    
    lazy var headerView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        return view
        
    }()
    
    lazy var gripperView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.lightGray
        
        return view
        
    }()
    
    lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.isTranslucent = true
        searchBar.backgroundColor = UIColor.clear
        searchBar.placeholder = String.localized("SearchBarPrompt")
        
        return searchBar
        
    }()
    
    lazy var separatorView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.alpha = 0.75
        
        return view
        
    }()
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
        
    }()
    
    private var headerHeightConstraint: NSLayoutConstraint?
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    // MARK: - Data
    
    private var locations: [Location] = []
    private var filteredLocations: [Location] = []
    private var branches: [Branch] = []
    private var selectedBranch: Branch?
    public var searchStyle = SearchStyle.none
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(headerView)
        self.headerView.addSubview(searchBar)
        self.headerView.addSubview(gripperView)
        self.headerView.addSubview(separatorView)
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()

    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let seperatorHeightConstraint = gripperView.heightAnchor.constraint(equalToConstant: 5)
        let searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 65)
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 68)
        
        seperatorHeightConstraint.isActive = true
        searchBarHeightConstraint.isActive = true
        headerHeightConstraint?.isActive = true
        
        let constraints = [headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           gripperView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),
                           gripperView.widthAnchor.constraint(equalToConstant: 36),
                           gripperView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                           searchBar.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                           searchBar.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                           searchBar.rightAnchor.constraint(equalTo: headerView.rightAnchor),
                           separatorView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
                           separatorView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                           separatorView.rightAnchor.constraint(equalTo: headerView.rightAnchor),
                           separatorView.heightAnchor.constraint(equalToConstant: 1),
                           tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.navigationColor
            themeable.searchBar.barTintColor = theme.accentColor
            themeable.searchBar.backgroundColor = theme.navigationColor
            themeable.searchBar.tintColor = theme.accentColor
            themeable.searchBar.textField?.textColor = theme.color
            themeable.separatorView.backgroundColor = theme.separatorColor
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawerVC = self.parent as? PulleyViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let fuzziness = 1.0 //0.75
        let threshold = 0.5 // 0.5
        
        var locs: [Location] = []
        
        if searchText != "" {
            
            for location in locations {
                
                if location.name.score(searchText, fuzziness: fuzziness) >= threshold {
                    
                    locs.append(location)
                    
                    continue
                    
                } else if location is ParkingLot {
                    
                    let loc = location as! ParkingLot
                    
                    if loc.address.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.subtitle!.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                    }
                    
                    
                } else if location is Shop {
                    
                    let loc = location as! Shop
                    
                    if loc.branch.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.place.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.street.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.quater.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.houseNumber.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    }
                    
                } else if location is Camera {
                    
                    let loc = location as! Camera
                    
                    if loc.title!.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if "360° Kamera".score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    }
                    
                }
                
            }
            
        }
        
        if searchText != "" {
            
            searchStyle = .none
            
        }
        
        filteredLocations = locs
        
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
        
        searchBar.resignFirstResponder()
        
    }
    
    // MARK: - PulleyDrawerViewControllerDelegate
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        if drawer.drawerPosition == .collapsed {
            headerHeightConstraint?.constant = 68.0 + drawerBottomSafeArea
        } else {
            headerHeightConstraint?.constant = 68.0
        }
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
    }
    
}
