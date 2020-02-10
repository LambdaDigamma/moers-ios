//
//  NewEventViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.06.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import MMUI

class MMEventsViewController: EventsViewController {

    var coordinator: EventCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfDisplayedUpcomingEvents = 15
        self.sectionUpcomingTitle = "IN DEN NÄCHSTEN TAGEN"
        self.sectionActiveTitle = "HEUTE"
        
    }
    
    override func loadData() {
        
        guard let eventManager = coordinator?.eventManager else { return }
        
        let eventObserver = eventManager.getEvents(shouldReload: true)
        
        eventObserver.observeNext { events in
            self.events = events
            self.rebuildData()
        }.dispose(in: bag)
        
        eventObserver.observeFailed { error in
            print(error.localizedDescription)
        }.dispose(in: bag)
        
    }
    
}
