//
//  TicketViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 16.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class TicketViewModel {
    
    private let ticket: Ticket
    
    public init(ticket: Ticket) {
        self.ticket = ticket
    }
    
    public var title: String {
        return ticket.title
    }
    
    public var date: String {
        return ticket.date
    }
    
    public var presale: String {
        return "\(String.localized("Presale")): \(ticket.pricePresale)€"
    }
    
    public var boxOffice: String {
        return "\(String.localized("BoxOffice")): \(ticket.priceBoxOffice)€"
    }
    
    public var discountSale: String {
        return "\(String.localized("PresaleDiscount")): \(ticket.pricePresaleDiscount)€ (*)"
    }
    
    public var discountBoxOfficeSale: String {
        return "\(String.localized("BoxOfficeDiscount")): \(ticket.priceBoxOfficeDiscount)€ (*)"
    }
    
    public var image: UIImage {
        
        switch ticket.type {
        case .mainTicket:
            return #imageLiteral(resourceName: "multiTicket")
        case .dayTicket(_):
            return #imageLiteral(resourceName: "singleTicket")
        case .moerzzTicket(_):
            return #imageLiteral(resourceName: "singleTicket")
        case .vipTicket:
            return #imageLiteral(resourceName: "vipTicket")
        case .earlyBird:
            return #imageLiteral(resourceName: "earlybird")
        }
        
    }
    
    public var url: URL {
        return ticket.buyURL ?? URL(string: "https://www.archiv.moers-festival.de/")!
    }
    
    public var buyEnabled: Bool {
        return ticket.buyURL == nil
    }
    
}
