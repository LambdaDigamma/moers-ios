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

class NewEventViewController: EventsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfDisplayedUpcomingEvents = 15
        
    }
    
    override func loadData() {
        
        let eventObserver = EventManager.shared.getMFEvents(forceReload: true)
        
        eventObserver.observeNext { events in
            self.events = events
            self.rebuildData()
        }.dispose(in: bag)
        
        eventObserver.observeFailed { error in
            print(error.localizedDescription)
        }.dispose(in: bag)
        
    }
    
}
