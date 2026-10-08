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
    private let locale: Locale
    
    public init(ticket: Ticket, locale: Locale = .autoupdatingCurrent) {
        self.ticket = ticket
        self.locale = locale
    }
    
    public var title: String {
        return ticket.title
    }
    
    public var date: String {
        return ticket.date
    }
    
    public var presale: String {
        return String(localized: "Presale: \(formattedPrice(ticket.pricePresale))")
    }
    
    public var boxOffice: String {
        return String(localized: "Box office: \(formattedPrice(ticket.priceBoxOffice))")
    }
    
    public var discountSale: String {
        return String(localized: "Presale (discount): \(formattedPrice(ticket.pricePresaleDiscount)) (*)")
    }
    
    public var discountBoxOfficeSale: String {
        return String(localized: "Box office (discount): \(formattedPrice(ticket.priceBoxOfficeDiscount)) (*)")
    }
    
    private func formattedPrice(_ value: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalized), amount.isFinite, amount >= 0 else {
            return String(localized: "Not available")
        }
        return amount.formatted(.currency(code: "EUR").locale(locale))
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
        return ticket.buyURL ?? URL(string: "https://moers.app/")!
    }
    
    public var buyEnabled: Bool {
        return ticket.buyURL == nil
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
