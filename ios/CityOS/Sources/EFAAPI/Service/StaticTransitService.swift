//
//  StaticTransitService.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import ModernNetworking
import Combine
import CoreLocation

public class StaticTransitService: TransitService {
    
    public var loadStations: () -> ([TransitLocation])
    
    public init() {
        self.loadStations = {
            return []
        }
    }
    
    public func findTransitLocation(
        for searchTerm: String,
        filtering objectFilter: ObjectFilter
    ) -> AnyPublisher<[TransitLocation], HTTPError> {
    
        return Just(loadStations())
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
        
    }
    
    public func findTransitLocation(
        for coordinate: CLLocationCoordinate2D,
        filtering objectFilter: ObjectFilter,
        maxNumberOfResults: Int
    ) -> AnyPublisher<[TransitLocation], HTTPError> {
        
        return Just(loadStations())
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
        
    }
    
    public func departureMonitor(id: Station.ID) -> AnyPublisher<DepartureMonitorData, Error> {
        
        let departureMonitor = DepartureMonitorData(
            date: .init(),
            name: "Duisburg Hbf",
            departures: [
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.actualDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 2)))
                        .setting(\.servingLine.direction, to: "Münster (Westf) Hbf")
                        .setting(\.servingLine.symbol, to: "S1")
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 5)))
                        .setting(\.servingLine.direction, to: "Dortmund Hbf")
                        .setting(\.servingLine.symbol, to: "ICE 933")
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 10)))
                        .setting(\.servingLine.direction, to: "Rheurdt Kirche")
                        .setting(\.servingLine.symbol, to: "SB 30")
                        .setting(\.platformName, to: "1")
                ),
                DepartureViewModel(
                    departure: ITDDeparture.stub()
                        .setting(\.regularDateTime,
                                  to: ITDDateTime.stub(date: .init(timeIntervalSinceNow: 60 * 20)))
                        .setting(\.servingLine.direction, to: "Duisburg Ruhrau")
                        .setting(\.servingLine.symbol, to: "RE 1")
                )
            ]
        )
        
        return Just(departureMonitor)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
    public func sendTripRequest(
        origin: String,
        destination: String,
        config: TripRequest.Configuration,
        tripDate: TripDate
    ) -> AnyPublisher<TripResponse, HTTPError> {
        
        let tripRequest = TripRequest(
            requestID: 0,
            odv: [],
            tripDateTime: .init(
                depArrType: .arrival,
                dateTime: .now(),
                dateRange: .init(dates: [ITDDate(weekday: 0, year: 0, month: 0, day: 0)])
            ),
            itinerary: .init(routeList: nil),
            tripOptions: .init(userDefined: true)
        )
        
        let response = TripResponse(language: "", sessionID: "", now: Date(), tripRequest: tripRequest)
        
        return Just(response)
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
        
    }
    
    public func geoObject(lines: [LineIdentifiable]) -> AnyPublisher<GeoITDRequest, HTTPError> {
        
        let geoRequest = ITDGeoObjectRequest(
            requestID: 0,
            geoObject: ITDGeoObject(
                geoObjectLineRequest: GeoObjectLineRequest(servingLines: .init(lines: [])),
                geoObjectLineResponse: GeoObjectLineResponse(lineItemList: .init(lineItems: []))
            )
        )
        
        let request = GeoITDRequest(
            language: "de",
            sessionID: 0,
            now: Date(),
            geoObjectRequest: geoRequest
        )
        
        return Just(request)
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
        
    }
    
}
