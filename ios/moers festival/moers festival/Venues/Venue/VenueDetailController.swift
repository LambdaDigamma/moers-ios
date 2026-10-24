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
import Events
import Pages
import Combine
import SafariServices
import FactoryKit

public class VenueDetailController: DefaultHostingController {
    
    @LazyInjected(\.locationEventService) var service
    
    public weak var coordinator: SharedCoordinator?
    
    public var showCloseButton: Bool = false
    public var onClose: (() -> Void)?
    public var onDidAppear: (() -> Void)?
    
    private let viewModel: VenueDetailViewModel
    let placeID: Place.ID
    private let layoutState: VenueDetailLayoutState
    public var presentationContext: VenueDetailPresentationContext {
        get { layoutState.presentationContext }
        set { layoutState.presentationContext = newValue }
    }
    private var cancellables = Set<AnyCancellable>()
    
    private let actionTransmitter: ActionTransmitter = .init()
    
    public init(
        placeID: Place.ID,
        presentationContext: VenueDetailPresentationContext = .automatic
    ) {
        
        self.viewModel = VenueDetailViewModel(placeID: placeID)
        self.placeID = placeID
        self.layoutState = VenueDetailLayoutState(presentationContext: presentationContext)
        super.init()
        
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func hostView() -> AnyView {
        VenueDetailScreen(
            viewModel: viewModel,
            layoutState: layoutState,
            actionTransmitter: actionTransmitter,
            onSelectEvent: { [weak self] eventID in self?.onSelectEvent(eventID: eventID) }
        )
            .toAnyView()
    }
    
    public func configureNavigationBar() {
        
        if showCloseButton {
            let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
            
            self.navigationItem.leftBarButtonItems = [
                closeItem
            ]
        } else {
            navigationItem.leftBarButtonItems = nil
        }
                
    }
    
    public func setupListeners() {
        
        actionTransmitter.showURL.sink { [weak self] (url: URL) in
            
            let viewController = SFSafariViewController(url: url)
            viewController.delegate = self
            self?.present(viewController, animated: true) { [weak self] in
                viewController.presentationController?.delegate = self
            }
            
        }.store(in: &cancellables)
        
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.loadData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onDidAppear?()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.subviews.first?.backgroundColor = .clear
        
        self.configureNavigationBar()
        self.setupListeners()
    }
    
    public func loadData() {
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let place = try await self.service.showVenue(id: self.placeID)
                
                await MainActor.run {
                    self.viewModel.name = place.name
                    self.viewModel.subtitle = "\(place.streetName ?? "") \(place.streetNumber ?? "")"
                    
                    if let streetName = place.streetName {
                        self.viewModel.addressLine1 = "\(streetName) \(place.streetNumber ?? "")"
                    }
                    
                    if let town = place.postalTown {
                        self.viewModel.addressLine2 = "\(town) \(place.postalCode ?? "")"
                    }
                    
                    self.viewModel.point = Point(latitude: place.lat, longitude: place.lng)
//                    self.viewModel.events = place.events.map {
//                        EventListItemViewModel(eventID: $0.id, title: $0.name, startDate: $0.startDate, endDate: $0.endDate, location: nil)
//                    }
                    self.viewModel.pageID = place.pageID
                    self.viewModel.refreshMapKitEnrichment()
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    // MARK: - Actions -
    
    public func onSelectEvent(eventID: Event.ID) {
        
        coordinator?.showEventDetail(eventID: eventID)
        
    }
    
    @objc private func close() {
        if let onClose {
            onClose()
        } else {
            dismiss(animated: true)
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

extension VenueDetailController: SFSafariViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) { [weak self] in self?.onDidAppear?() }
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDidAppear?()
    }
}
