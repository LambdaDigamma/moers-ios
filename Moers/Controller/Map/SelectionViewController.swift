//
//  SelectionViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 10.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Pulley
import MapKit

class SelectionViewController: UIViewController {

    lazy var headerView: UIView = { ViewFactory.blankView() }()
    lazy var gripperView: UIView = { ViewFactory.blankView() }()
    lazy var titleLabel: UILabel = { ViewFactory.label() }()
    lazy var separatorView: UIView = { ViewFactory.blankView() }()
    lazy var closeButton: UIButton = { ViewFactory.button() }()
    lazy var tableView: UITableView = { ViewFactory.tableView() }()
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
        self.closeButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchResultCell)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           headerView.heightAnchor.constraint(equalToConstant: 68),
                           gripperView.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 6),
                           gripperView.widthAnchor.constraint(equalToConstant: 36),
                           gripperView.heightAnchor.constraint(equalToConstant: 5),
                           gripperView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                           separatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                           separatorView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                           separatorView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                           separatorView.heightAnchor.constraint(equalToConstant: 0.5),
                           closeButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           closeButton.heightAnchor.constraint(equalToConstant: 25),
                           closeButton.widthAnchor.constraint(equalToConstant: 25),
                           tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            themeable.gripperView.backgroundColor = UIColor.lightGray
            themeable.headerView.backgroundColor = theme.backgroundColor
            themeable.closeButton.tintColor = theme.decentColor
            
        }
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
        
        cell.searchImageView.backgroundColor = UIColor.clear
        cell.searchImageView.image = nil
        cell.searchImageView.layer.borderWidth = 0
        
        if let shop = clusteredLocations[indexPath.row] as? Store {
            
            cell.titleLabel.text = shop.title
            cell.subtitleLabel.text = shop.subtitle
            
            cell.searchImageView.contentMode = .scaleAspectFit
            cell.searchImageView.layer.borderColor = UIColor.black.cgColor
            cell.searchImageView.layer.borderWidth = 1
            cell.searchImageView.layer.cornerRadius = 7
            cell.searchImageView.backgroundColor = AppColor.yellow
            
            if let image = ShopIconDrawer.annotationImage(from: shop.branch) {
                
                if let img = UIImage.imageResize(imageObj: image, size: CGSize(width: cell.searchImageView.bounds.width / 2, height: cell.searchImageView.bounds.height / 2), scaleFactor: 0.75) {
                    
                    cell.searchImageView.image = img
                    
                }
                
            }
            
        } else if let parkingLot = clusteredLocations[indexPath.row] as? ParkingLot {
            
            cell.titleLabel.text = parkingLot.title
            cell.subtitleLabel.text = parkingLot.subtitle
            
            cell.searchImageView.image = #imageLiteral(resourceName: "parkingLot")
            
        } else if let camera = clusteredLocations[indexPath.row] as? Camera {
            
            cell.titleLabel.text = camera.title
            cell.subtitleLabel.text = camera.localizedCategory
            
            cell.searchImageView.image = #imageLiteral(resourceName: "camera")
            
        } else if let ebike = clusteredLocations[indexPath.row] as? BikeChargingStation {
            
            cell.titleLabel.text = ebike.title
            cell.subtitleLabel.text = ebike.localizedCategory
            
            cell.searchImageView.image = #imageLiteral(resourceName: "ebike")
            
        } else if let petrolStation = clusteredLocations[indexPath.row] as? PetrolStation {
            
            cell.titleLabel.text = petrolStation.name
            cell.subtitleLabel.text = petrolStation.brand
            
            cell.searchImageView.image = #imageLiteral(resourceName: "petrol")
            
        }
        
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
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell, let _ = clusteredLocations[indexPath.row] as? Store {
            
            cell.searchImageView.backgroundColor = AppColor.yellow
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 81
        
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
