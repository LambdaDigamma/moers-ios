//
//  RubbishStreetPickerItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Combine
import Core
import BLTNBoard
import CoreLocation
import OSLog
import FactoryKit
import RubbishFeature

class RubbishStreetPickerItem: BLTNPageItem, PickerViewDelegate, PickerViewDataSource {

    @LazyInjected(\.rubbishService) private var rubbishService: RubbishService
    @LazyInjected(\.geocodingService) private var geocodingService: GeocodingService
    @LazyInjected(\.locationService) private var locationService: LocationService
    
    private var streets: [RubbishFeature.RubbishCollectionStreet] = []
    private var streetLoading: AnyCancellable?
    private var authorizationObservation: AnyCancellable?
    private var streetEstimation: AnyCancellable?
    
    private let logger = Logger(.coreUi)
    
    private lazy var picker = PickerView()
    
    public var selectedStreet: RubbishFeature.RubbishCollectionStreet {
        return streets[picker.currentSelectedRow]
    }
    
    override init(title: String) {
        super.init(title: title)
        
        self.setupPicker()
        
    }

    init(title: String, rubbishService: RubbishService, locationService: LocationService, geocodingService: GeocodingService) {
        super.init(title: title)
        self.rubbishService = rubbishService
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.setupPicker()
    }

    override func setUp() {
        super.setUp()
        loadStreets()
    }

    override func tearDown() {
        streetLoading = nil
        authorizationObservation = nil
        streetEstimation = nil
        super.tearDown()
    }
    
    private func setupPicker() {
        
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.systemBackground
        
    }
    
    private func loadStreets() {
        
        let task = Task { [weak self, rubbishService] in
            guard !Task.isCancelled, self != nil else { return }
            do {
                let streets = try await rubbishService.loadRubbishCollectionStreets()
                guard !Task.isCancelled, let self else { return }
                self.streets = streets
                self.picker.reloadPickerView()
                self.loadUserLocationForStreetEstimation()
            } catch {
                guard !Task.isCancelled else { return }
                self?.logger.error("Loading rubbish collection streets failed: \(error.localizedDescription)")
            }
        }
        streetLoading = AnyCancellable { task.cancel() }
        
    }
    
    private func loadUserLocationForStreetEstimation() {
        
        let task = Task { [weak self, locationService] in
            guard !Task.isCancelled, self != nil else { return }
            for await authorizationStatus in locationService.authorizationStatuses {
                guard !Task.isCancelled else { return }
                if authorizationStatus == .authorizedWhenInUse {
                    self?.estimateUserStreet()
                }
            }
        }
        authorizationObservation = AnyCancellable { task.cancel() }
        
    }
    
    private func estimateUserStreet() {
        let task = Task { [weak self, locationService, geocodingService] in
            guard !Task.isCancelled, self != nil else { return }
            locationService.requestCurrentLocation()
            do {
                for try await location in locationService.locations {
                    guard !Task.isCancelled else { return }
                    let placemark = try await geocodingService.placemark(from: location)
                    guard !Task.isCancelled, let self else { return }
                    if let index = self.streets.firstIndex(where: { $0.street.contains(placemark.street) }) {
                        self.picker.selectRow(index, animated: true)
                        self.picker.adjustCurrentSelectedAfterOrientationChanges()
                    }
                    break
                }
            } catch {
                guard !Task.isCancelled else { return }
                self?.logger.error("Failed to estimate street: \(error.localizedDescription, privacy: .private)")
            }
        }
        streetEstimation = AnyCancellable { task.cancel() }
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
