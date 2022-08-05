//
//  RubbishStreetPickerItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Core
import BLTNBoard
import Gestalt
import CoreLocation
import OSLog
import Combine
import Resolver
import RubbishFeature

class RubbishStreetPickerItem: BLTNPageItem, PickerViewDelegate, PickerViewDataSource {

    @LazyInjected var rubbishService: RubbishService
    @LazyInjected var geocodingService: GeocodingService
    @LazyInjected var locationService: LocationService
    
    private var streets: [RubbishFeature.RubbishCollectionStreet] = []
    private var accentColor = UIColor.clear
    private var decentColor = UIColor.clear
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger(.coreUi)
    
    private lazy var picker = PickerView()
    
    public var selectedStreet: RubbishFeature.RubbishCollectionStreet {
        return streets[picker.currentSelectedRow]
    }
    
    override init(title: String) {
        
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
        
        let streets = rubbishService.loadRubbishCollectionStreets()
        
        streets
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        self?.logger.error("Loading rubbish collection streets failed: \(error.localizedDescription)")
                    default: break
                }
                
            }, receiveValue: { (streets: [RubbishFeature.RubbishCollectionStreet]) in
                
                self.streets = streets
                self.picker.reloadPickerView()
                
                self.loadUserLocationForStreetEstimation()
                
            })
            .store(in: &cancellables)
        
    }
    
    private func loadUserLocationForStreetEstimation() {
        
        locationService.authorizationStatus.sink { (authorizationStatus: CLAuthorizationStatus) in
            if authorizationStatus == .authorizedWhenInUse {
                self.estimateUserStreet()
            }
        }
        .store(in: &cancellables)
        
    }
    
    private func estimateUserStreet() {
        
        locationService.requestCurrentLocation()
        
        locationService.location.sink { (_: Subscribers.Completion<Error>) in
            
        } receiveValue: { (location: CLLocation) in
            self.checkStreetExistance(for: location)
        }
        .store(in: &cancellables)
        
    }
    
    private func checkStreetExistance(for location: CLLocation) {
        
        geocodingService
            .placemark(from: location)
            .receive(on: DispatchQueue.main)
            .sink { (_: Subscribers.Completion<Error>) in
                
            } receiveValue: { placemark in
                
                let userStreet = placemark.street
                
                if let rubbishStreet = self.streets.filter({ $0.street.contains(userStreet) }).first {
                    
                    self.picker.selectRow(self.streets.firstIndex(of: rubbishStreet) ?? 0, animated: true)
                    self.picker.adjustCurrentSelectedAfterOrientationChanges()
                    
                }
                
            }
            .store(in: &cancellables)
        
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
