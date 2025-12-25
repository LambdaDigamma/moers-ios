//
//  EventExtras.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Core
import Foundation
import CoreLocation

public struct EventExtras: Codable, Equatable {
    
    // Common Attributes
    
    public var location: String? = nil
    public var street: String? = nil
    public var houseNumber: String? = nil
    public var place: String? = nil
    public var postcode: String? = nil
    public var lat: Double? = nil
    public var lng: Double? = nil
    public var organizer: String? = nil
    
    public var openEnd: Bool? = nil
    public var sametime: Int? = nil
    
    // Moers Festival Attributes
    
    public var needsFestivalTicket: Bool? = nil
    public var isFree: Bool? = nil
    public var visitWithExtraTicket: Bool? = nil
    public var color: String? = nil
    public var descriptionEN: String? = nil
    public var iconURL: String? = nil
    public var isMovingAct: Bool? = nil
    public var shape: [[Double]]? = nil
    public var tickets: String? = nil
    public var isPreview: Bool? = nil
    
    enum CodingKeys: String, CodingKey {
        case location
        case street
        case houseNumber
        case place
        case postcode
        case lat
        case lng
        case organizer
        case openEnd = "open_end"
        case sametime
        case needsFestivalTicket
        case isFree
        case visitWithExtraTicket
        case color = "color"
        case descriptionEN
        case iconURL
        case isMovingAct
        case shape
        case tickets
        case isPreview = "is_preview"
    }
    
    public init(
        location: String? = nil,
        street: String? = nil,
        houseNumber: String? = nil,
        place: String? = nil,
        postcode: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        organizer: String? = nil,
        needsFestivalTicket: Bool? = nil,
        isFree: Bool? = nil,
        visitWithExtraTicket: Bool? = nil,
        color: String? = nil,
        descriptionEN: String? = nil,
        iconURL: String? = nil,
        isMovingAct: Bool? = nil,
        shape: [[Double]]? = nil,
        tickets: String? = nil,
        isPreview: Bool? = nil
    ) {
        
        self.needsFestivalTicket = needsFestivalTicket
        self.isFree = isFree
        self.visitWithExtraTicket = visitWithExtraTicket
        self.location = location
        self.street = street
        self.houseNumber = houseNumber
        self.place = place
        self.postcode = postcode
        self.lat = lat
        self.lng = lng
        self.organizer = organizer
        
        self.color = color
        self.descriptionEN = descriptionEN
        self.iconURL = iconURL
        self.isMovingAct = isMovingAct
        self.shape = shape
        self.tickets = tickets
        self.isPreview = isPreview
        
    }
    
    public var icon: URL? {
        return URL(string: iconURL ?? "")
    }
    
    public var coordinate: CLLocationCoordinate2D? {
        
        if let lat = lat, let lng = lng {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        } else {
            return nil
        }
        
    }
    
}

extension EventExtras: Identifiable, Stubbable {
    
    public var id: Int {
        get {
            return 0
        }
        set {}
    }
    
    public static func stub(withID id: Int) -> EventExtras {
        
        return EventExtras(location: nil,
                           street: nil,
                           houseNumber: nil,
                           place: nil,
                           postcode: nil,
                           lat: nil,
                           lng: nil,
                           organizer: nil,
                           needsFestivalTicket: nil,
                           isFree: nil,
                           visitWithExtraTicket: nil,
                           color: nil,
                           descriptionEN: nil,
                           iconURL: nil,
                           isMovingAct: nil,
                           shape: nil)
        
    }
    
}
