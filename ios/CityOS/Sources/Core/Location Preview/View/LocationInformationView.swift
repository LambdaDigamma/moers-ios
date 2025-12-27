//
//  LocationInformationView.swift
//  MMUI
//
//  Created by Lennart Fischer on 26.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit
import Combine

public class LocationInformationView: UIView {
    
    public var locationName = CurrentValueSubject<String, Never>("nicht bekannnt")
    public var locationDetails = CurrentValueSubject<String, Never>("nicht bekannt")
    public private(set) var startNavigation: PassthroughSubject<Void, Never>!
    
    private var cancellables = Set<AnyCancellable>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.bindData()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - UI
    
    private lazy var locationNameLabel = { CoreViewFactory.label() }()
    private lazy var locationDetailsLabel = { CoreViewFactory.label() }()
    private lazy var routeButton = { CoreViewFactory.roundedButton() }()
    
    private func setupUI() {
        
        self.addSubview(locationNameLabel)
        self.addSubview(locationDetailsLabel)
        self.addSubview(routeButton)
        
        self.layer.cornerRadius = 16
        
        self.locationNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        self.locationDetailsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        self.locationNameLabel.numberOfLines = 0
        self.locationDetailsLabel.numberOfLines = 0
        
        self.routeButton.setTitle(String(localized: "Route", bundle: .module), for: .normal)
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            locationNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            locationNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            locationNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            locationDetailsLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 4),
            locationDetailsLabel.leadingAnchor.constraint(equalTo: locationNameLabel.leadingAnchor),
            locationDetailsLabel.trailingAnchor.constraint(equalTo: locationNameLabel.trailingAnchor),
            routeButton.topAnchor.constraint(equalTo: locationDetailsLabel.bottomAnchor, constant: 16),
            routeButton.leadingAnchor.constraint(equalTo: locationNameLabel.leadingAnchor),
            routeButton.trailingAnchor.constraint(equalTo: locationNameLabel.trailingAnchor),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        #if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
        #endif
        self.locationNameLabel.textColor = UIColor.label
        self.locationDetailsLabel.textColor = UIColor.label
        self.routeButton.setBackgroundColor(color: UIPackageConfiguration.accentColor, forState: .normal)
        self.routeButton.setTitleColor(UIPackageConfiguration.onAccentColor, for: .normal)
        
    }
    
    private func bindData() {
        
        locationName.map { Optional($0) }.assign(to: \.text, on: locationNameLabel).store(in: &cancellables)
        locationDetails.map { Optional($0) }.assign(to: \.text, on: locationDetailsLabel).store(in: &cancellables)
        
        routeButton.addAction(UIAction(handler: { _ in
            
            self.startNavigation.send(())
            
        }), for: .touchUpInside)
        
    }
    
}
