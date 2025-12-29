//
//  VenueDetailController.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import UIKit
import SwiftUI
import MMEvents
import MMPages
import Combine
import SafariServices
import Factory

public class VenueDetailController: DefaultHostingController {
    
    @LazyInjected(\.locationEventService) var service
    
    public weak var coordinator: SharedCoordinator?
    
    public var showCloseButton: Bool = false
    
    private let viewModel: VenueDetailViewModel
    private let placeID: Place.ID
    private var cancellables = Set<AnyCancellable>()
    
    private let actionTransmitter: ActionTransmitter = .init()
    
    public init(placeID: Place.ID) {
        
        self.viewModel = VenueDetailViewModel(placeID: placeID)
        self.placeID = placeID
        super.init()
        
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func hostView() -> AnyView {
        VenueDetailScreen(
            viewModel: viewModel,
            actionTransmitter: actionTransmitter,
            onSelectEvent: onSelectEvent(eventID:)
        )
            .toAnyView()
    }
    
    public func configureNavigationBar() {
        
        if showCloseButton {
            let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
            
            self.navigationItem.leftBarButtonItems = [
                closeItem
            ]
        }
                
    }
    
    public func setupListeners() {
        
        actionTransmitter.showURL.sink { (url: URL) in
            
            let viewController = SFSafariViewController(url: url)
            
            self.present(viewController, animated: true)
            
        }.store(in: &cancellables)
        
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.loadData()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.setupListeners()
    }
    
    public func loadData() {
        
        self.service
            .showVenue(id: placeID)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (place: Place) in
                self.viewModel.name = place.name
                self.viewModel.subtitle = "\(place.streetName ?? "") \(place.streetNumber ?? "")"
                
                if let streetName = place.streetName {
                    self.viewModel.addressLine1 = "\(streetName) \(place.streetNumber ?? "")"
                }
                
                if let town = place.postalTown {
                    self.viewModel.addressLine2 = "\(town) \(place.postalCode ?? "")"
                }
                
                self.viewModel.point = Point(latitude: place.lat, longitude: place.lng)
//                self.viewModel.events = place.events.map {
//                    EventListItemViewModel(eventID: $0.id, title: $0.name, startDate: $0.startDate, endDate: $0.endDate, location: nil)
//                }
                self.viewModel.pageID = place.pageID
            }
            .store(in: &viewModel.cancellables)
            
    }
    
    // MARK: - Actions -
    
    public func onSelectEvent(eventID: Event.ID) {
        
        coordinator?.pushEventDetail(eventID: eventID)
        
    }
    
    @objc private func close() {
        
        self.dismiss(animated: true)
        
    }
    
}
