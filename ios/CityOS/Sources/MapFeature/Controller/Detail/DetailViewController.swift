//
//  DetailViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 13.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import MapKit

import Pulley
import Combine
import Resolver
import Core

public class DetailViewController: UIViewController {
    
    @LazyInjected var locationService: LocationService
    
    public var coordinator: MapCoordintor?
    
    private lazy var gripperView: UIView = { CoreViewFactory.blankView() }()
    private lazy var imageView: UIImageView = { CoreViewFactory.imageView() }()
    private lazy var nameLabel: UILabel = { CoreViewFactory.label() }()
    private lazy var subtitleLabel: UILabel = { CoreViewFactory.label() }()
    private lazy var contentView: UIScrollView = { CoreViewFactory.scrollView() }()
    private lazy var closeButton: UIButton = { CoreViewFactory.button() }()
    private lazy var routeButton: UIButton = { CoreViewFactory.button() }()
    
    private var cancellables = Set<AnyCancellable>()
    private let entryManager: EntryManagerProtocol
    
    private weak var child: UIViewController? {
        willSet {
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            contentView.removeFromSuperview()
            contentView = CoreViewFactory.scrollView()
            
            self.view.addSubview(contentView)
            
            contentView.topAnchor.constraint(equalTo: routeButton.bottomAnchor, constant: 8).isActive = true
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -20).isActive = true
            
        }
    }
    
    public var selectedLocation: Location? { didSet { setupLocation(selectedLocation) } }
    
    init(entryManager: EntryManagerProtocol) {
        
        self.entryManager = entryManager
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
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
        
        let constraints: [NSLayoutConstraint] = [
            gripperView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 6),
            gripperView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gripperView.heightAnchor.constraint(equalToConstant: 5),
            gripperView.widthAnchor.constraint(equalToConstant: 36),
            closeButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 25),
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            imageView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 47),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 21),
            routeButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            routeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            routeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            routeButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
    }
    
    @objc private func navigateViaMaps() {
        
        guard let location = selectedLocation else { return }
        
//        AnalyticsManager.shared.logNavigation(location)
        
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
            
            vc.removeFromParent()
            
            self.dismiss(animated: false, completion: nil)
            
            drawer.setDrawerContentViewController(controller: contentDrawer, animated: true)
            drawer.setDrawerPosition(position: .collapsed, animated: true)
            
            mapDrawer.map.deselectAnnotation(selectedLocation, animated: true)
            
        }
        
    }
    
    private func setupLocation(_ location: Location?) {
        
        guard let location = location else { return }
        
        self.nameLabel.text = location.name
        self.subtitleLabel.text = UIProperties.detailSubtitle(for: location)
        self.imageView.image = UIProperties.detailImage(for: location)
        
        self.calculateETA()
        
        // todo: Generify Detail Morphing
        
        if location is Entry {
            
            morphDetailEntry()
            
        } else if selectedLocation is Camera {
            
            morphDetailCamera()
            
        } else if selectedLocation is PetrolStationViewModel {
            
            morphDetailPetrolStation()
            
        }
        
    }
    
    private func calculateETA() {
        
        self.routeButton.setTitle("Route", for: .normal)
        
        guard let destinationCoordinate = selectedLocation?.location.coordinate else { return }
        
        locationService.authorizationStatus.sink { _ in
            self.setupDistance(to: destinationCoordinate)
        }
        .store(in: &cancellables)
        
    }
    
    private func setupDistance(to destinationCoordinate: CLLocationCoordinate2D) {
        
        locationService.requestCurrentLocation()
        locationService.location.sink { _ in
            
        } receiveValue: { (location: CLLocation) in
            
            let directions = self.buildDirectionRequest(from: location.coordinate, to: destinationCoordinate)
            
            directions.calculateETA(completionHandler: { (response, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let estimate = response else { return }
                
                self.routeButton.setTitle("Route (\(Int(floor(estimate.expectedTravelTime / 60))) min)", for: .normal)
                
            })
            
        }
        .store(in: &cancellables)
        
    }
    
    private func buildDirectionRequest(from source: CLLocationCoordinate2D,
                                       to destination: CLLocationCoordinate2D) -> MKDirections {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let request = MKDirections.Request()
        
        request.source = source
        request.destination = destination
        
        request.transportType = .automobile
        
        return MKDirections(request: request)
        
    }
    
    // MARK: - Detail
    
    private func morphDetailEntry() {
        
        let viewController = DetailEntryViewController.fromStoryboard()
        
        viewController.coordinator = coordinator
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedEntry = selectedLocation as? Entry
        
    }
    
    private func morphDetailParking() {
        
        let viewController = DetailParkingViewController()
        
        self.add(asChildViewController: viewController)
        
//        viewController.selectedParkingLot = selectedLocation as? ParkingLot
        
    }
    
    private func morphDetailCamera() {
        
        let viewController = DetailCameraViewController()
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedCamera = selectedLocation as? Camera
        
    }
    
    private func morphDetailPetrolStation() {
        
        let viewController = DetailPetrolStationViewController.fromStoryboard()
        
        viewController.coordinator = coordinator
        
        self.add(asChildViewController: viewController)
        
        viewController.selectedPetrolStation = selectedLocation as? PetrolStationViewModel
        
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        
        self.child = viewController
        
        self.addChild(viewController)
        self.contentView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        viewController.view.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        
        viewController.didMove(toParent: self)
        
    }
        
}

extension DetailViewController: PulleyDrawerViewControllerDelegate {
    
    public func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 130.0 + (bottomSafeArea - 49)
    }
    
    public func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        if let pulleyVC = self.parent as? MainViewController {
            
            let height = pulleyVC.mapViewController.map.frame.height
            
            if pulleyVC.currentDisplayMode == .panel {
                return height - 49.0 - 16.0 - 16.0 - 64.0 - 50.0 - 16.0
            }
            
        }
        
        return 264.0 + bottomSafeArea
    }
    
    public func supportedDrawerPositions() -> [PulleyPosition] {
        
        if let pulleyVC = self.parent as? PulleyViewController {
            
            if pulleyVC.currentDisplayMode == .panel {
                
                self.gripperView.isHidden = true
                
                return [PulleyPosition.partiallyRevealed]
            }
            
        }
        
        return PulleyPosition.all
    }
    
}

