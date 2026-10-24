//
//  ExperimentViewController.swift
//  CityOS
//
//  Created by Lennart Fischer on 09.10.26.
//

import UIKit
import MapKit

class ExperimentViewController: UIViewController {

    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupSheet()
    }
    
    private func setupUI() {
        
        self.view.addSubview(mapView)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupSheet() {
        
        let viewController = ExperimentSearchViewController()
        let nav = UINavigationController(rootViewController: viewController)
        
        if let sheetPresentationController = nav.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.largestUndimmedDetentIdentifier = .large
//            sheetPresentationController.prefersPageSizing = false
            sheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheetPresentationController.prefersEdgeAttachedInCompactHeight = true
            
            if #available(iOS 27.0, *) {
//                sheetPresentationController.preferredPlacement = .leading
            }
            
        }
        
        present(nav, animated: true)

        
    }

}

class ExperimentSearchViewController: UIViewController {
    
    
    
}

#Preview {
    ExperimentViewController()
}
