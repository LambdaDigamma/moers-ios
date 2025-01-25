//
//  TripSearchViewController.swift
//  
//
//  Created by Lennart Fischer on 05.04.22.
//

#if canImport(UIKit)

import UIKit
import SwiftUI
import EFAAPI

public struct TripSearchActivityData: Codable {
    
    public let origin: String
    public let destination: String
    public let originID: StatelessIdentifier
    public let destinationID: StatelessIdentifier
    
    public init(
        origin: String,
        destination: String,
        originID: StatelessIdentifier,
        destinationID: StatelessIdentifier
    ) {
        self.origin = origin
        self.destination = destination
        self.originID = originID
        self.destinationID = destinationID
    }
    
}

public class TripSearchViewController: UIHostingController<TripSearchScreen> {
    
    private let viewModel: TripSearchViewModel
    
    public init(viewModel: TripSearchViewModel) {
        
        self.viewModel = viewModel
        
        super.init(rootView: TripSearchScreen(
            viewModel: viewModel
        ))
        
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateUserActivity()
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateUserActivity()
        
    }
    
    private func updateUserActivity() {
        
        let activity = TransportationUserActivity.configureTransportationSearch(
            origin: viewModel.origin?.name ?? "",
            destination: viewModel.destination?.name ?? ""
        )
        
        guard let originName = viewModel.origin?.name,
              let destinationName = viewModel.destination?.name,
              let originID = viewModel.originID,
              let destinationID = viewModel.destinationID else {
            return
        }
        
        let data = TripSearchActivityData(
            origin: originName,
            destination: destinationName,
            originID: originID,
            destinationID: destinationID
        )
        
        do {
            try activity.setTypedPayload(data)
        } catch {
            print(error)
        }
        
        activity.becomeCurrent()
        
        self.view.window?.windowScene?.userActivity = activity
        
    }
    
}

#endif
