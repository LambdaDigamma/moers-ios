//
//  EventDetailViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 01.02.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MapKit
import MMEvents
import Combine

class MFEventDetailViewController: EventDetailViewController {

    public var coordinator: EventCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = viewModel.model {
            // TODO: Update event
//            AnalyticsManager.shared.logOpenDetailEvent(event)
        }
        
        self.activateActivity()
        
    }
    
}

extension MFEventDetailViewController {
    
    private func activateActivity() {
        
        let activity = NSUserActivity(activityType: "de.okfn.niederrhein.moers-festival.openEvent")
        
        viewModel.title.sink { (title: String?) in
            
            if let title = title {
                self.setupActivity(title, activity: activity)
            }
            
        }
        .store(in: &cancellables)
        
    }
    
    private func setupActivity(_ title: String, activity: NSUserActivity) {
        
        if let event = viewModel.model {
            
            let title = "\(String.localized("ShowSpecificEvent")) \"\(title)\""
            
            activity.title = title
            activity.isEligibleForSearch = true
            activity.expirationDate = event.endDate
            activity.userInfo = ["id": event.id]
            activity.keywords = [String.localized("EventKeyword"),
                                 String.localized("MFKeyword"),
                                 event.extras?.location ?? "Ort",
                                 event.name]
            
            if #available(iOS 12.0, *) {
                activity.isEligibleForPrediction = true
                activity.persistentIdentifier = "event-\(event.id)"
            }
            
            userActivity = activity
            userActivity!.becomeCurrent()
            
        }
        
    }
    
}
