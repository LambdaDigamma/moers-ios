//
//  RebuildDetailViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 13.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import Gestalt
import Pulley
import Crashlytics

class RebuildDetailViewController: UIViewController, CLLocationManagerDelegate {

    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.startUpdatingLocation()
        return manager
    }()
    
    lazy var gripperView: UIView = { ViewFactory.blankView() }()
    lazy var imageView: UIImageView = { ViewFactory.imageView() }()
    lazy var nameLabel: UILabel = { ViewFactory.label() }()
    lazy var subtitleLabel: UILabel = { ViewFactory.label() }()
    lazy var contentView: UIScrollView = { ViewFactory.scrollView() }()
    lazy var closeButton: UIButton = { ViewFactory.button() }()
    lazy var routeButton: UIButton = { ViewFactory.button() }()
    
    var selectedLocation: Location? { didSet { setupLocation(selectedLocation) } }
    
    weak var child: UIViewController? = nil
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let drawerVC = self.parent as? PulleyViewController {
            drawerVC.delegate = self
        }
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.view.addSubview(gripperView)
        self.view.addSubview(imageView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(subtitleLabel)
        self.view.addSubview(contentView)
        self.view.addSubview(closeButton)
        self.view.addSubview(routeButton)
        
        gripperView.backgroundColor = UIColor.lightGray
        gripperView.layer.cornerRadius = 2.5
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        subtitleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        closeButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        routeButton.layer.cornerRadius = 8
        routeButton.clipsToBounds = true
        routeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [gripperView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 6),
                           gripperView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           gripperView.heightAnchor.constraint(equalToConstant: 5),
                           gripperView.widthAnchor.constraint(equalToConstant: 36),
                           closeButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           closeButton.heightAnchor.constraint(equalToConstant: 25),
                           closeButton.widthAnchor.constraint(equalToConstant: 25),
                           imageView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           imageView.widthAnchor.constraint(equalToConstant: 47),
                           imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                           nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
                           nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
                           nameLabel.rightAnchor.constraint(equalTo: closeButton.leftAnchor, constant: -8),
                           subtitleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                           subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
                           subtitleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           subtitleLabel.heightAnchor.constraint(equalToConstant: 21),
                           routeButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
                           routeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           routeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           routeButton.heightAnchor.constraint(equalToConstant: 50),
                           contentView.topAnchor.constraint(equalTo: routeButton.bottomAnchor, constant: 8),
                           contentView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           contentView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -20)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.nameLabel.textColor = theme.color
            themeable.subtitleLabel.textColor = theme.color
            themeable.closeButton.tintColor = theme.decentColor
            themeable.subtitleLabel.textColor = theme.decentColor
            themeable.routeButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.routeButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .selected)
            themeable.routeButton.setTitleColor(theme.backgroundColor, for: .normal)
            
        }
        
    }
    
    private func navigateViaMaps() {
        
        guard let location = selectedLocation else { return }
        
        var type = ""
        
        if location is Shop {
            type = "Shop"
        } else if location is ParkingLot {
            type = "Parking Lot"
        } else if location is Camera {
            type = "Camera"
        } else if location is BikeChargingStation {
            type = "E-Bike Charger"
        }
        
        Answers.logCustomEvent(withName: "Navigation", customAttributes: ["type": type, "name": location.name])
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.location.coordinate))
        mapItem.name = location.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    @objc private func close() {
        
        if let drawer = self.parent as? PulleyViewController {
            
            let contentDrawer = RebuildContentViewController()
            
            guard let vc = child else { return }
            
            vc.removeFromParentViewController()
            
            self.dismiss(animated: false, completion: nil)
            
            drawer.setDrawerContentViewController(controller: contentDrawer, animated: false)
            drawer.setDrawerPosition(position: .collapsed, animated: false)
            
        }
        
    }
    
    private func setupLocation(_ location: Location?) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        if let shop = location as? Store {
            
            nameLabel.text = shop.name
            subtitleLabel.text = shop.branch
            
            if let image = ShopIconDrawer.annotationImage(from: shop.branch) {
                
                if let img = UIImage.imageResize(imageObj: image, size: CGSize(width: imageView.bounds.width / 2, height: imageView.bounds.height / 2), scaleFactor: 0.75) {
                    
                    imageView.backgroundColor = UIColor(red: 0xFF, green: 0xF5, blue: 0x00, alpha: 1)
                    imageView.image = img
                    imageView.contentMode = .scaleAspectFit
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.borderWidth = 1
                    imageView.layer.cornerRadius = 7
                    
                }
                
            }
            
            
            
        } else if let parkingLot = selectedLocation as? ParkingLot {
            
            nameLabel.text = parkingLot.name
            subtitleLabel.text = "Parkplatz"
            imageView.image = #imageLiteral(resourceName: "parkingLot")
            
            morphDetailParking()
            
        } else if let camera = selectedLocation as? Camera {
            
            nameLabel.text = camera.title
            subtitleLabel.text = "360° Kamera"
            imageView.image = #imageLiteral(resourceName: "camera")
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        
        guard let sourceCoordinate = locationManager.location?.coordinate else { return }
        guard let destinationCoordinate = selectedLocation?.location.coordinate else { return }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        let request = MKDirectionsRequest()
        
        request.source = source
        request.destination = destination
        
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculateETA { (response, error) -> Void in
            
            if error == nil {
                
                if let estimate = response {
                    
                    self.routeButton.setTitle("Route (\(Int(floor(estimate.expectedTravelTime / 60))) min)", for: .normal)
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Detail
    
    private func morphDetailParking() {
        
        let viewController = RebuildDetailParkingViewController()
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedParkingLot = selectedLocation as? ParkingLot
        
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        
        child = viewController
        
        addChildViewController(viewController)
        
        var height: CGFloat = 700
        
        guard let loc = selectedLocation else { return }
        
        if loc is Shop {
            height = DetailContentHeight.shop
        } else if loc is ParkingLot {
            height = DetailContentHeight.parkingLot
        } else if loc is Camera {
            height = DetailContentHeight.camera
        } else if loc is BikeChargingStation {
            height = DetailContentHeight.bikeCharger
        }
        
        // Add Child View as Subview
        contentView.contentSize = CGSize(width: contentView.bounds.width, height: height)
        contentView.addSubview(viewController.view)
        contentView.isUserInteractionEnabled = true
        
        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
}

extension RebuildDetailViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 154.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
}
