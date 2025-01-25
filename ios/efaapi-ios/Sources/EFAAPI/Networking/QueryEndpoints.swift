//
//  QueryEndpoints.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation

internal enum QueryEndpoints: String, Codable, CaseIterable {
    
    /// StopFinder-Request
    case stopFinder = "XML_STOPFINDER_REQUEST"
    
    /// ServingLines-Request
    case servingLines = "XML_SERVINGLINES_REQUEST"
    
    /// Trip-Request
    case trip = "XML_TRIP_REQUEST2"
    
    /// PersonalSchedule-Request
    case personalSchedule = "XML_PS_REQUEST2"
    
    /// DepartureMonitor-Request
    case departureMonitor = "XML_DM_REQUEST"
    
    /// DMTTP-Request
    case departureMonitorTimetablePeriod = "XML_DMTTP_REQUEST"
    
    /// TripStopTimes-Request
    case tripStopTimes = "XML_TRIPSTOPTIMES_REQUEST"
    
    /// StopSeqCoord-Request
    case stopSeqCoord = "XML_STOPSEQCOORD_REQUEST"
    
    /// LineStop-Request
    case lineStop = "XML_LINESTOP_REQUEST"
    
    /// StopTimetable-Request
    case stopTimetable = "XML_STT_REQUEST"
    
    /// CoordInfo-Request
    case coordInfo = "XML_COORD_REQUEST"
    
    /// GeoObject-Request
    case geoObject = "XML_GEOOBJECT_REQUEST"
    
    /// ParkObject-Request
    case parkObject = "XML_PARKOJECT_REQUEST"
    
    /// OpArea-Request
    case opArea = "XML_OPAREA_REQUEST"
    
    /// StopList-Request
    case stopList = "XML_STOPLIST_REQUEST"
    
    /// AdditionalInformation-Request
    case additionalInformation = "XML_ADDINFO_REQUEST"
    
    
    case realtimeTrip = "XML_GETRTFORTRIP_REQUEST"
    
}
