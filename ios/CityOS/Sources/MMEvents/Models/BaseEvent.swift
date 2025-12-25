//
//  BaseEvent.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Core
import Foundation
import ModernNetworking

public protocol BaseEvent: Model, Stubbable, Equatable {
    
    associatedtype ID = Identifiable
    
    var id: ID { get }
    var name: String { get set }
    var description: String? { get set }
    var url: String? { get set }
    var startDate: Date? { get set }
    var endDate: Date? { get set }
    var category: String? { get set }
    var imagePath: String? { get set }
    
    var web: URL? { get }
    var image: URL? { get }
    
//    public var organisationID: Int?
//    public var organisation: Organisation?
//    public var entry: Entry?
//    public var page: Page?

    var place: Place? { get set }
    
    var extras: EventExtras? { get set }
    
}

public extension BaseEvent {

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
    }
    
    var web: URL? { return URL(string: url ?? "") }

    var image: URL? { return URL(string: imagePath ?? "") }

}

extension Array {

    public func chronologically() -> [Self.Element] where Self.Element : BaseEvent {

        return sorted { (e1: Self.Element, e2: Self.Element) -> Bool in
            return e1.startDate ?? Date(timeIntervalSinceNow: 3 * 365 * 24 * 60 * 60)
                < e2.startDate ?? Date(timeIntervalSinceNow: 3 * 365 * 24 * 60 * 60)
        }

    }

}

