//
//  PulleyPosition.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//


import UIKit

/**
 Represents a Pulley drawer position.
 
 - collapsed:         When the drawer is in its smallest form, at the bottom of the screen.
 - partiallyRevealed: When the drawer is partially revealed.
 - open:              When the drawer is fully open.
 - closed:            When the drawer is off-screen at the bottom of the view. Note: Users cannot close or reopen the drawer on their own. You must set this programatically
 */
@objc public class PulleyPosition: NSObject {
    
    public static let collapsed = PulleyPosition(rawValue: 0)
    public static let partiallyRevealed = PulleyPosition(rawValue: 1)
    public static let open = PulleyPosition(rawValue: 2)
    public static let closed = PulleyPosition(rawValue: 3)
    
    public static let all: [PulleyPosition] = [
        .collapsed,
        .partiallyRevealed,
        .open,
        .closed
    ]
    
    public static let compact: [PulleyPosition] = [
        .collapsed,
        .open,
        .closed
    ]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        if rawValue < 0 || rawValue > 3 {
            print("PulleyViewController: A raw value of \(rawValue) is not supported. You have to use one of the predefined values in PulleyPosition. Defaulting to `collapsed`.")
            self.rawValue = 0
        } else {
            self.rawValue = rawValue
        }
    }
    
    /// Return one of the defined positions for the given string.
    ///
    /// - Parameter string: The string, preferably obtained by `stringFor(position:)`
    /// - Returns: The `PulleyPosition` or `.collapsed` if the string didn't match.
    public static func positionFor(string: String?) -> PulleyPosition {
        
        guard let positionString = string?.lowercased() else {
            
            return .collapsed
        }
        
        switch positionString {
            
        case "collapsed":
            return .collapsed
            
        case "partiallyrevealed":
            return .partiallyRevealed
            
        case "open":
            return .open
            
        case "closed":
            return .closed
            
        default:
            print("PulleyViewController: Position for string '\(positionString)' not found. Available values are: collapsed, partiallyRevealed, open, and closed. Defaulting to collapsed.")
            return .collapsed
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let position = object as? PulleyPosition else {
            return false
        }

        return self.rawValue == position.rawValue
    }
    
    public override var description: String {
        switch rawValue {
        case 0:
            return "collapsed"
        case 1:
            return "partiallyrevealed"
        case 2:
            return "open"
        case 3:
            return "closed"
        default:
            return "collapsed"
        }
    }
}