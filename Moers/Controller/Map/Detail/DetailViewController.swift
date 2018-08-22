//
//  DetailViewController.swift
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

struct DetailContentHeight {
    
    static let shop: CGFloat = 550
    static let parkingLot: CGFloat = 220
    static let camera: CGFloat = 80
    static let bikeCharger: CGFloat = 520
    
}

class DetailViewController: UIViewController {
    
    lazy var gripperView: UIView = { ViewFactory.blankView() }()
    lazy var imageView: UIImageView = { ViewFactory.imageView() }()
    lazy var nameLabel: UILabel = { ViewFactory.label() }()
    lazy var subtitleLabel: UILabel = { ViewFactory.label() }()
    lazy var contentView: UIScrollView = { ViewFactory.scrollView() }()
    lazy var closeButton: UIButton = { ViewFactory.button() }()
    lazy var routeButton: UIButton = { ViewFactory.button() }()
    
    var selectedLocation: Location? { didSet { setupLocation(selectedLocation) } }
    
    weak var child: UIViewController? = nil {
        willSet {
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            contentView.removeFromSuperview()
            contentView = ViewFactory.scrollView()
            
            self.view.addSubview(contentView)
            
            contentView.topAnchor.constraint(equalTo: routeButton.bottomAnchor, constant: 8).isActive = true
            contentView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
            contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -20).isActive = true
            
        }
    }
    
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
        routeButton.addTarget(self, action: #selector(navigateViaMaps), for: .touchUpInside)
        contentView.bounces = false
        
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
                           routeButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
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
            themeable.routeButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.routeButton.setTitleColor(theme.backgroundColor, for: .normal)
            
        }
        
    }
    
    @objc private func navigateViaMaps() {
        
        guard let location = selectedLocation else { return }
        
        Answers.logCustomEvent(withName: "Navigation", customAttributes: ["type": location.category, "name": location.name])
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.location.coordinate))
        mapItem.name = location.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    @objc private func close() {
        
        if let drawer = self.parent as? MainViewController {
            
            guard let contentDrawer = drawer.contentViewController else { return }
            guard let mapDrawer = drawer.mapViewController else { return }
            
            guard let vc = child else { return }
            
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            
            vc.removeFromParentViewController()
            
            self.dismiss(animated: false, completion: nil)
            
            drawer.setDrawerContentViewController(controller: contentDrawer, animated: true)
            drawer.setDrawerPosition(position: .collapsed, animated: true)
            
            if let annotation = selectedLocation as? MKAnnotation {
                mapDrawer.map.deselectAnnotation(annotation, animated: true)
            }
            
        }
        
    }
    
    private func setupLocation(_ location: Location?) {
        
        self.nameLabel.text = location?.name
        self.subtitleLabel.text = location?.detailSubtitle
        self.imageView.image = location?.detailImage
        
        self.calculateETA()
        
        // TODO: Generify Detail Morphing
        
        if let shop = location as? Store {
            
//            if let image = ShopIconDrawer.annotationImage(from: shop.branch) {
//
//                if let img = UIImage.imageResize(imageObj: image, size: CGSize(width: imageView.bounds.width / 2, height: imageView.bounds.height / 2), scaleFactor: 0.75) {
//
//                    imageView.backgroundColor = UIColor(red: 0xFF, green: 0xF5, blue: 0x00, alpha: 1)
//                    imageView.image = img
//                    imageView.contentMode = .scaleAspectFit
//                    imageView.layer.borderColor = UIColor.black.cgColor
//                    imageView.layer.borderWidth = 1
//                    imageView.layer.cornerRadius = 7
//
//                }
//
//            }
            
            morphDetailShop()
            
        } else if let parkingLot = selectedLocation as? ParkingLot {
            
            morphDetailParking()
            
        } else if let camera = selectedLocation as? Camera {
            
            morphDetailCamera()
            
        }
        
    }
    
    private func calculateETA() {
        
        self.routeButton.setTitle("Route", for: .normal)
        
        guard let sourceCoordinate = LocationManager.shared.lastLocation?.coordinate else { return }
        guard let destinationCoordinate = selectedLocation?.location.coordinate else { return }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        let request = MKDirectionsRequest()
        
        request.source = source
        request.destination = destination
        
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculateETA { (response, error) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let estimate = response else { return }
            
            self.routeButton.setTitle("Route (\(Int(floor(estimate.expectedTravelTime / 60))) min)", for: .normal)
            
        }
        
        
    }
    
    // MARK: - Detail
    
    private func morphDetailParking() {
        
        let viewController = DetailParkingViewController()
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedParkingLot = selectedLocation as? ParkingLot
        
    }
    
    private func morphDetailCamera() {
        
        let viewController = DetailCameraViewController()
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedCamera = selectedLocation as? Camera
        
    }
    
    private func morphDetailShop() {
        
        let viewController = DetailShopViewController.fromStoryboard()
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedShop = selectedLocation as? Store
        
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        
        self.child = viewController
        self.addChildViewController(viewController)
        
        guard let loc = selectedLocation else { return }
        
        self.contentView.contentSize = CGSize(width: contentView.bounds.width, height: loc.detailHeight + 49)
        self.contentView.addSubview(viewController.view)
        self.contentView.isUserInteractionEnabled = true
        
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
        
    }
    
}

extension DetailViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 130.0 + (bottomSafeArea - 49)
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        if let pulleyVC = self.parent as? MainViewController {
            
            let height = pulleyVC.mapViewController.map.frame.height
            
            if pulleyVC.currentDisplayMode == .leftSide {
                return height - 49.0 - 16.0 - 16.0 - 64.0 - 50.0 - 16.0
            }
            
        }
        
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        
        if let pulleyVC = self.parent as? PulleyViewController {
            
            if pulleyVC.currentDisplayMode == .leftSide {
                
                self.gripperView.isHidden = true
                
                return [PulleyPosition.partiallyRevealed]
            }
            
        }
        
        return PulleyPosition.all
    }
    
}
