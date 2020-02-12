//
//  RubbishStreetPickerItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Gestalt
import CoreLocation
import MMAPI
import MMUI

class RubbishStreetPickerItem: BLTNPageItem, PickerViewDelegate, PickerViewDataSource {

    private let locationManager: LocationManagerProtocol
    private let rubbishManager: RubbishManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    
    private var streets: [RubbishCollectionStreet] = []
    private var accentColor = UIColor.clear
    private var decentColor = UIColor.clear
    
    private lazy var picker = PickerView()
    
    public var selectedStreet: RubbishCollectionStreet {
        return streets[picker.currentSelectedRow]
    }
    
    init(title: String,
         locationManager: LocationManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         rubbishManager: RubbishManagerProtocol) {
        
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        self.rubbishManager = rubbishManager
        
        super.init(title: title)
        
        self.setupPicker()
        self.loadStreets()
        
    }
    
    private func setupPicker() {
        
        picker.delegate = self
        picker.dataSource = self
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func loadStreets() {
        
        let streets = rubbishManager.loadRubbishCollectionStreets()
        
        streets.receive(on: DispatchQueue.main)
            .observeNext { (streets: [RubbishCollectionStreet]) in
            
            self.streets = streets
            self.picker.reloadPickerView()
            
            self.loadUserLocationForStreetEstimation()
            
        }.dispose(in: self.bag)
        
        streets.observeFailed { (error: Error) in
            print("Loading Rubbish Collection Streets Failed: \(error.localizedDescription)")
        }.dispose(in: bag)
        
    }
    
    private func loadUserLocationForStreetEstimation() {
        
        locationManager.authorizationStatus.observeNext { authorizationStatus in
            
            if authorizationStatus == .authorizedWhenInUse {
                self.estimateUserStreet()
            }
            
        }.dispose(in: bag)
        
    }
    
    private func estimateUserStreet() {
        
        locationManager.requestCurrentLocation()
        locationManager.location.observeNext { location in
            
            self.checkStreetExistance(for: location)
            
        }.dispose(in: bag)
        
    }
    
    private func checkStreetExistance(for location: CLLocation) {
        
        geocodingManager.placemark(from: location).observeNext { placemark in
            
            let userStreet = placemark.street
            
            if let rubbishStreet = self.streets.filter({ $0.street.contains(userStreet) }).first {
                
                self.picker.selectRow(self.streets.firstIndex(of: rubbishStreet) ?? 0, animated: true)
                self.picker.adjustCurrentSelectedAfterOrientationChanges()
                
            }
            
        }.dispose(in: bag)
        
    }
    
    // MARK: - BLNTPageItem
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.heightAnchor.constraint(equalToConstant: 120).isActive = true
        descriptionLabel?.minimumScaleFactor = 0.5
        descriptionLabel?.adjustsFontSizeToFitWidth = true
        
        return [picker]
        
    }
    
    // MARK: - PickerViewDelegate / PickerViewDataSource
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return streets.count
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return streets[row].displayName
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        if highlighted {
            label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
            label.textColor = accentColor
        } else {
            label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)
            label.textColor = decentColor
        }
        
    }
    
}

extension RubbishStreetPickerItem: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.accentColor = theme.accentColor
        self.decentColor = theme.decentColor
        self.picker.backgroundColor = theme.backgroundColor
    }
    
}
