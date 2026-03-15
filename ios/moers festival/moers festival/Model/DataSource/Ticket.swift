//
//  Ticket.swift
//  moers festival
//
//  Created by Lennart Fischer on 30.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import Foundation

struct Ticket {
    
    let title: String
    let date: String
    let pricePresale: String
    let priceBoxOffice: String
    let pricePresaleDiscount: String
    let priceBoxOfficeDiscount: String
    let buyURL: URL?
    let type: TicketType
    
    static let tickets2020: [Ticket] = [
        
        // Festival Ticket
        Ticket(title: String.localized("FestivalTickets"),
               date: String.localized("FestivalDate"),
               pricePresale: "151",
               priceBoxOffice: "160",
               pricePresaleDiscount: "76",
               priceBoxOfficeDiscount: "80",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-festivalkarte-29-mai-01-juni-2020-in-moers-enni-eventhalle-am-29-5-2020/e1478379"),
               type: .mainTicket),
        
        // MÖRZZ Tickets
        Ticket(title: String.localized("MoerzzTicket"),
               date: String.localized("FridayDate"),
               pricePresale: "15",
               priceBoxOffice: "20",
               pricePresaleDiscount: "8",
               priceBoxOfficeDiscount: "10",
               buyURL: nil,
               type: .moerzzTicket(day: 1)),
        Ticket(title: String.localized("MoerzzTicket"),
               date: String.localized("SaturdayDate"),
               pricePresale: "15",
               priceBoxOffice: "20",
               pricePresaleDiscount: "8",
               priceBoxOfficeDiscount: "10",
               buyURL: nil,
               type: .moerzzTicket(day: 2)),
        Ticket(title: String.localized("MoerzzTicket"),
               date: String.localized("SundayDate"),
               pricePresale: "15",
               priceBoxOffice: "20",
               pricePresaleDiscount: "8",
               priceBoxOfficeDiscount: "10",
               buyURL: nil,
               type: .moerzzTicket(day: 3)),
        Ticket(title: String.localized("MoerzzTicket"),
               date: String.localized("MondayDate"),
               pricePresale: "15",
               priceBoxOffice: "20",
               pricePresaleDiscount: "8",
               priceBoxOfficeDiscount: "10",
               buyURL: nil,
               type: .moerzzTicket(day: 3)),
        
        // Day Tickets
        Ticket(title: String.localized("DayTicket"),
               date: String.localized("FridayDate"),
               pricePresale: "45",
               priceBoxOffice: "50",
               pricePresaleDiscount: "22",
               priceBoxOfficeDiscount: "25",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-tagesticket-freitag-29052020-in-moers-enni-eventhalle-am-29-5-2020/e1478372"),
               type: .dayTicket(day: 1)),
        Ticket(title: String.localized("DayTicket"),
               date: String.localized("SaturdayDate"),
               pricePresale: "70",
               priceBoxOffice: "75",
               pricePresaleDiscount: "35",
               priceBoxOfficeDiscount: "38",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-tagesticket-samstag-30052020-in-moers-enni-eventhalle-am-30-5-2020/e1478370"),
               type: .dayTicket(day: 2)),
        Ticket(title: String.localized("DayTicket"),
               date: String.localized("SundayDate"),
               pricePresale: "70",
               priceBoxOffice: "75",
               pricePresaleDiscount: "35",
               priceBoxOfficeDiscount: "38",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-tagesticket-sonntag-31052020-in-moers-enni-eventhalle-am-31-5-2020/e1478369"),
               type: .dayTicket(day: 3)),
        Ticket(title: String.localized("DayTicket"),
               date: String.localized("MondayDate"),
               pricePresale: "45",
               priceBoxOffice: "50",
               pricePresaleDiscount: "22",
               priceBoxOfficeDiscount: "25",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-tagesticket-montag-01062020-in-moers-enni-eventhalle-am-1-6-2020/e1478367"),
               type: .dayTicket(day: 4)),
        
        // VIP Ticket
        Ticket(title: String.localized("VIPTicket"),
               date: String.localized("FestivalDate"),
               pricePresale: "270",
               priceBoxOffice: "280",
               pricePresaleDiscount: "135",
               priceBoxOfficeDiscount: "140",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-festivalkarte-29-mai-01-juni-2020-in-moers-enni-eventhalle-am-29-5-2020/e1478379"),
               type: .vipTicket),
        
        // Early Bird
        Ticket(title: String.localized("EarlyBird"),
               date: String.localized("FestivalDate"),
               pricePresale: "130",
               priceBoxOffice: "/ ",
               pricePresaleDiscount: "65",
               priceBoxOfficeDiscount: "/ ",
               buyURL: URL(string: "https://moersfestival.reservix.de/tickets-moers-festival-2020-festivalkarte-29-mai-01-juni-2020-in-moers-enni-eventhalle-am-29-5-2020/e1478379"),
               type: .earlyBird),
    ]
    
    enum TicketType {
        case earlyBird
        case mainTicket
        case moerzzTicket(day: Int)
        case dayTicket(day: Int)
        case vipTicket
    }
    
}
