//
//  MMEventsViewController.swift
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
        self.sectionUpcomingTitle = String.localized("Upcoming").uppercased()
        self.sectionActiveTitle = String.localized("ActiveEventsHeadline").uppercased()
        
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
    
    override func filterActive(events: [Event]) -> [Event] {
        
        return events.filter { (event) -> Bool in
            return isActive(event: event)
        }
        
    }
    
    override func filterUpcoming(events: [Event]) -> [Event] {
        
        return events.filter({ !$0.isLongEvent }).filter { (event) -> Bool in
            return !isActive(event: event)
        }
        
    }
    
    private func isActive(event: Event) -> Bool {
        
        if let startDate = event.startDate {
            return startDate.isToday
        } else if let startDate = event.startDate, let endDate = event.endDate {
            return (startDate...endDate).contains(Date())
        } else if event.startDate == nil {
            return false
        } else {
            return false
        }
        
    }
    
}
