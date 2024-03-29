//
//  SelectionViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 10.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Gestalt
import Pulley
import MapKit

// todo: Update Selection View Controller
class SelectionViewController: UIViewController {

    lazy var headerView: UIView = { CoreViewFactory.blankView() }()
    lazy var gripperView: UIView = { CoreViewFactory.blankView() }()
    lazy var titleLabel: UILabel = { CoreViewFactory.label() }()
    lazy var separatorView: UIView = { CoreViewFactory.blankView() }()
    lazy var closeButton: UIButton = { CoreViewFactory.button() }()
    lazy var tableView: UITableView = { CoreViewFactory.tableView() }()
    
    // swiftlint:disable:next force_cast
    lazy var drawer: MainViewController = { self.parent as! MainViewController }()
    
    public var annotation: MKAnnotation?
    public var clusteredLocations: [Location] = [] {
        didSet {
            
            self.titleLabel.text = "\(clusteredLocations.count) " + String.localized("Entries")
            self.tableView.reloadData()
            
        }
    }
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea + 50, right: 0.0)
        }
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        drawer.delegate = self
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.view.addSubview(headerView)
        self.view.addSubview(gripperView)
        self.view.addSubview(closeButton)
        self.headerView.addSubview(titleLabel)
        self.view.addSubview(tableView)
        self.view.addSubview(separatorView)
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        self.gripperView.layer.cornerRadius = 2.5
        self.separatorView.backgroundColor = UIColor.lightGray
        self.separatorView.alpha = 0.5
        self.closeButton.setImage(UIImage(systemName: "xmark.circle.fill")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchResultCell)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 68),
            gripperView.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 6),
            gripperView.widthAnchor.constraint(equalToConstant: 36),
            gripperView.heightAnchor.constraint(equalToConstant: 5),
            gripperView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            separatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            closeButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 25),
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0)
        ]

        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    @objc private func close() {
        
        guard let contentDrawer = drawer.contentViewController else { return }
        guard let mapDrawer = drawer.mapViewController else { return }
        
        self.dismiss(animated: false, completion: nil)
        
        drawer.setDrawerContentViewController(controller: contentDrawer, animated: true)
        drawer.setDrawerPosition(position: .collapsed, animated: true)
        
        if let annotation = annotation {
            mapDrawer.map.deselectAnnotation(annotation, animated: true)
        }
        
    }
    
}

extension SelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return clusteredLocations.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifier.searchResultCell,
            for: indexPath
        ) as! SearchResultTableViewCell
        // swiftlint:disable:previous force_cast
        
        let location = clusteredLocations[indexPath.row]
        
        cell.titleLabel.text = location.title ?? ""
        cell.subtitleLabel.text = UIProperties.detailSubtitle(for: location)
        cell.searchImageView.image = UIProperties.detailImage(for: location)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        drawer.setDrawerContentViewController(controller: drawer.detailViewController, animated: false)
        drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
        
        drawer.detailViewController.selectedLocation = clusteredLocations[indexPath.row]
        
        if let mapController = drawer.primaryContentViewController as? MapViewController {
            
            let coordinate = self.clusteredLocations[indexPath.row].location.coordinate
            
            mapController.map.setCenter(coordinate, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension SelectionViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        let height = drawer.mapViewController.map.frame.height
        
        if drawer.currentDisplayMode == .panel {
            return height - 49.0 - 16.0 - 16.0 - 64.0 - 50.0 - 16.0
        }
        
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        
        if drawer.currentDisplayMode == .panel {
            
            self.gripperView.isHidden = true
            
            return [PulleyPosition.partiallyRevealed]
        }
        
        return PulleyPosition.all
        
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open
        
        if drawer.currentDisplayMode == .panel {
        
            tableView.isScrollEnabled = true
        
        }
        
    }
    
}

extension SelectionViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.titleLabel.textColor = theme.color
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor = theme.separatorColor
        self.gripperView.backgroundColor = UIColor.lightGray
        self.headerView.backgroundColor = theme.backgroundColor
        self.closeButton.tintColor = theme.decentColor
    }
    
}
