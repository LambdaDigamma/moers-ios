//
//  DetailViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import Pulley

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var routeButton: DesignableButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func close(_ sender: UIButton) {
        
        if let drawer = self.parent as? PulleyViewController {
            let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
            
            guard let vc = child else { return }
            
            vc.removeFromParentViewController()
            
            self.dismiss(animated: false) {
                
                
                
            }
            
            drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
            drawer.setDrawerPosition(position: .collapsed, animated: false)
            
        }
        
    }
    
    @IBAction func navigateViaMeps(_ sender: UIButton) {
        
        guard let location = selectedLocation else { return }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.location.coordinate, addressDictionary: nil))
        mapItem.name = "\(location.name)"
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    var selectedLocation: Location? {
        
        didSet {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            if let shop = selectedLocation as? Shop {
                
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
                
                morphDetailShop()
                
            } else if let parkingLot = selectedLocation as? ParkingLot {
                
                nameLabel.text = parkingLot.name
                subtitleLabel.text = "Parkplatz"
                imageView.image = #imageLiteral(resourceName: "parkingLot")
                
                morphDetailParking()
                
            } else if let camera = selectedLocation as? Camera {
                
                nameLabel.text = camera.title
                subtitleLabel.text = "360° Kamera"
                imageView.image = #imageLiteral(resourceName: "camera")
                
                morphDetailCamera()
                
            } else if let bikeCharger = selectedLocation as? BikeChargingStation {
                
                nameLabel.text = bikeCharger.title
                subtitleLabel.text = "E-Bike Ladestation"
                imageView.image = nil
                
                morphDetailBikeCharger()
                
            }
            
        }
        
    }
    
    weak var child: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let drawerVC = self.parent as? PulleyViewController {
            drawerVC.delegate = self
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
    
    private func morphDetailParking() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailParkingViewController") as! DetailParkingViewController
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedParkingLot = selectedLocation as? ParkingLot
        
    }
    
    private func morphDetailShop() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailShopViewController") as! DetailShopViewController
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedShop = selectedLocation as? Shop
        
    }
    
    private func morphDetailCamera() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailCameraViewController") as! DetailCameraViewController
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedCamera = selectedLocation as? Camera
        
    }
    
    private func morphDetailBikeCharger() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailBikeChargingStationViewController") as! DetailBikeChargingStationViewController
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedBikeChargingStation = selectedLocation as? BikeChargingStation
        
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        
        child = viewController
        
        addChildViewController(viewController)
        
        // Add Child View as Subview
        contentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    fileprivate func resetNavBar() {
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.85, green: 0.12, blue: 0.09, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.alpha = 1
        }
        
    }
    
}

extension DetailViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 154
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        
        
        if progress != 0 {
            
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.85, green: 0.12, blue: 0.09, alpha: 1.0).darker(amount: progress / 3)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white.darker(amount: progress / 3)]
            
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.alpha = 1 - (progress / 3)
            }
            
        } else {
            
            resetNavBar()
            
        }
        
        
    }
    
}
