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
import CoreLocation
import OSLog
import Combine
import Factory
import RubbishFeature

class RubbishStreetPickerItem: BLTNPageItem, PickerViewDelegate, PickerViewDataSource {

    @LazyInjected(\.rubbishService) var rubbishService
    @LazyInjected(\.geocodingService) var geocodingService
    @LazyInjected(\.locationService) var locationService
    
    private var streets: [RubbishFeature.RubbishCollectionStreet] = []
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
        picker.backgroundColor = UIColor.systemBackground
        
    }
    
    private func loadStreets() {
        
        Task {
            do {
                let streets = try await rubbishService.loadRubbishCollectionStreets()
                
                await MainActor.run {
                    self.streets = streets
                    self.picker.reloadPickerView()
                    self.loadUserLocationForStreetEstimation()
                }
            } catch {
                self.logger.error("Loading rubbish collection streets failed: \(error.localizedDescription)")
            }
        }
        
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
        Task {
            do {
                let placemark = try await geocodingService.placemark(from: location)
                
                await MainActor.run {
                    let userStreet = placemark.street
                    
                    if let rubbishStreet = self.streets.filter({ $0.street.contains(userStreet) }).first {
                        self.picker.selectRow(self.streets.firstIndex(of: rubbishStreet) ?? 0, animated: true)
                        self.picker.adjustCurrentSelectedAfterOrientationChanges()
                    }
                }
            } catch {
                self.logger.error("Failed to get placemark for location: \(error.localizedDescription, privacy: .private)")
            }
        }
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
            label.textColor = UIColor.systemYellow
        } else {
            label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)
            label.textColor = UIColor.secondaryLabel
        }
        
    }
    
}
