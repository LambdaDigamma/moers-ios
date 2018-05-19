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

class RebuildDetailViewController: UIViewController {

    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()
    
    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
        
    }()
    
    lazy var nameLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        return label
        
    }()
    
    lazy var subtitleLabel: UILabel = {
       
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        
        return label
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupConstraints()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
                           imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           imageView.widthAnchor.constraint(equalToConstant: 47),
                           imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                           nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
                           nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
                           nameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            
            
        }
        
    }
    
}
