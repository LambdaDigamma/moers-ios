//
//  BaseFeed.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import Core
import ModernNetworking

public protocol BaseFeed: Model, Stubbable, Equatable {

    associatedtype ID = Identifiable
    associatedtype Post = BasePost
    
    var id: ID { get }
    var name: String { get set }
    var posts: [Post] { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    
}
