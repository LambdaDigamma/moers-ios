//
//  ITDDateTime.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XMLCoder

public struct ITDDateTime: Codable, Equatable, Hashable, DynamicNodeDecoding {
    
    /// Represents the start of the current timetable period (ttp)
    public var ttpFrom: String?
    
    /// Represents the end of the current timetable period (ttp)
    public var ttpTo: String?
    
    public var date: ITDDate?
    public var time: ITDTime?
    
    public var parsedDate: Date? {
        if let date = date, let time = time {
            return DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: date.year,
                month: date.month,
                day: date.day,
                hour: time.hour,
                minute: time.minute
            ).date
        }
        return nil
    }
    
    public enum CodingKeys: String, CodingKey {
        case ttpFrom = "ttpFrom"
        case ttpTo = "ttpTo"
        case date = "itdDate"
        case time = "itdTime"
    }
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.ttpFrom, CodingKeys.ttpTo:
                return .attribute
            default:
                return .element
        }
    }
    
    public static func now(_ now: Date = Date()) -> ITDDateTime {
        return stub(date: now)
    }
    
    public static func stub(date: Date = Date()) -> ITDDateTime {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        return ITDDateTime(
            ttpFrom: nil,
            ttpTo: nil,
            date: ITDDate(
                weekday: 0,
                year: components.year ?? 2020,
                month: components.month ?? 1,
                day: components.day ?? 1
            ),
            time: ITDTime(
                hour: components.hour ?? 10,
                minute: components.minute ?? 0
            )
        )
    }
    
}
