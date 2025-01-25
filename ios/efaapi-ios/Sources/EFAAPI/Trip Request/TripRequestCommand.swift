//
//  TripRequestCommand.swift
//  
//
//  Created by Lennart Fischer on 16.12.22.
//

import Foundation

public enum TripRequestCommand {
    
    case noOperation
    case changeRequest
    case tripRetoure
    case tripGoOn
    case tripPrev
    case tripNext
    case tripLast
    case tripFirst
    case printSingleview(index: Int)
    
    public var value: String {
        switch self {
            case .noOperation:
                return "nop"
            case .changeRequest:
                return "changeRequest"
            case .tripRetoure:
                return "tripRetoure"
            case .tripGoOn:
                return "tripGoOn"
            case .tripPrev:
                return "tripPrev"
            case .tripNext:
                return "tripNext"
            case .tripLast:
                return "tripLast"
            case .tripFirst:
                return "tripFirst"
            case .printSingleview(let index):
                return "printSingleview:\(index)"
        }
    }
    
}
