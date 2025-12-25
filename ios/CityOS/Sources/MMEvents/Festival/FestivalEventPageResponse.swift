//
//  FestivalEventPageResponse.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Core
import MMPages
import Foundation
import MediaLibraryKit
import ModernNetworking

public struct FestivalEventPageResponse: Model {
    
    public let header: Media?
    public let event: Event?
    public let page: MMPages.Page?
    public let place: Place?
    
    public enum CodingKeys: String, CodingKey {
        case header = "header"
        case event = "event"
        case page = "page"
        case place = "place"
    }
    
}
