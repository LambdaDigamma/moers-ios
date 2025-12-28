//
//  TicketsListViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

struct TicketsListViewModel {
    
    enum TicketType {
        case mainTicket
        case moerzzTicket(day: Int)
        case dayTicket(day: Int)
        case vipTicket
        case earlyBirdTicket
    }
    
    private let mainTicket: Ticket
    private let dayTickets: [Ticket]
    private let moerzzTickets: [Ticket]
    private let vipTicket: Ticket
    private let earlyBirdTicket: Ticket
    
    init(mainTicket: Ticket, dayTickets: [Ticket], moerzzTickets: [Ticket], vipTicket: Ticket, earlyBirdTicket: Ticket) {
        self.mainTicket = mainTicket
        self.dayTickets = dayTickets
        self.moerzzTickets = moerzzTickets
        self.vipTicket = vipTicket
        self.earlyBirdTicket = earlyBirdTicket
    }
    
    public func image(for type: TicketType) -> UIImage {
        
        switch type {
        case .mainTicket:
            return #imageLiteral(resourceName: "multiTicket")
        case .dayTicket:
            return #imageLiteral(resourceName: "singleTicket")
        case .moerzzTicket:
            return #imageLiteral(resourceName: "singleTicket")
        case .vipTicket:
            return #imageLiteral(resourceName: "vipTicket")
        case .earlyBirdTicket:
            return #imageLiteral(resourceName: "earlybird")
        }
        
    }
    
    public func ticket(for type: TicketType) -> Ticket {
    
        switch type {
        case .mainTicket:
            return mainTicket
        case .dayTicket(let day):
            return dayTickets[day - 1]
        case .moerzzTicket(let day):
            return moerzzTickets[day - 1]
        case .vipTicket:
            return vipTicket
        case .earlyBirdTicket:
            return earlyBirdTicket
        }
        
    }
    
}
