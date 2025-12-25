//
//  BasePost.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import Core
import ModernNetworking
import MediaLibraryKit

public protocol BasePost: Model, Stubbable, Equatable {
    
    associatedtype ID = Identifiable
    associatedtype FeedID = Identifiable
    associatedtype PageID = Identifiable
    
    var id: ID { get }
    var title: String { get set }
    var summary: String { get set }
    var feedID: FeedID? { get set }
    var pageID: PageID? { get set }
    var externalHref: String? { get set }
//    var media: [Medi]
//    var media: [BaseMedia] { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    
}
