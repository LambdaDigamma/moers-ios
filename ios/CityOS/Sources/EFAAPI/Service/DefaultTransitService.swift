//
//  DefaultEFAService.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import XMLCoder
import ModernNetworking
import CoreLocation

public class DefaultTransitService: TransitService {
    
    private let languageCode: String
    nonisolated(unsafe) private let loader: HTTPLoader
    private let standardCoordinateOutputFormat: CoordinateOutputFormat = .wgs84
    
    public init(
        loader: HTTPLoader,
        languageCode: String = "de"
    ) {
        self.loader = loader
        self.languageCode = languageCode
    }
    
    // MARK: - Stop Finder
    
    /// Send a stop finder request with a specified search text
    /// and receive a stop finder response.
    ///
    /// - Parameters:
    ///   - searchText: Search term
    ///   - objectFilter: Specifies the stop types returned by the api (`ObjectFilter`)
    /// - Returns: The stop finder response publisher
    public func sendRawStopFinderRequest(
        searchText: String,
        objectFilter: ObjectFilter = .noFilter,
        maxNumberOfResults: Int = 50
    ) async throws -> StopFinderResponse {
        
        var request = HTTPRequest(
            method: .get,
            path: QueryEndpoints.stopFinder.rawValue
        )
        
        request.queryItems = [
            URLQueryItem(name: "name_sf", value: searchText),
            URLQueryItem(name: "locationServerActive", value: "1"),
            URLQueryItem(name: "anyObjFilter_sf", value: "\(objectFilter.rawValue)"),
            URLQueryItem(name: "type_sf", value: "any"),
            URLQueryItem(name: "anyMaxSizeHitList", value: "\(maxNumberOfResults)"),
            URLQueryItem(name: "coordOutputFormat", value: CoordinateOutputFormat.wgs84.rawValue),
            URLQueryItem(name: "UTFMacro", value: "1"),
        ]
        
        let result = await loader.load(request)
        
        return try await result.decodingXML(
            StopFinderResponse.self,
            request: request,
            decoder: Self.defaultDecoder
        )
        
    }
    
    public func findTransitLocation(
        for searchTerm: String,
        filtering objectFilter: ObjectFilter
    ) async throws -> [TransitLocation] {
        
        let response = try await sendRawStopFinderRequest(searchText: searchTerm, objectFilter: objectFilter)
        
        return response.stopFinderRequest
            .odv
            .name?
            .elements?
            .sorted(by: { $0.matchQuality > $1.matchQuality })
            .map({ TransitLocation(odvNameElement: $0) }) ?? []
        
    }
    
    public func findTransitLocation(
        for coordinate: CLLocationCoordinate2D,
        filtering objectFilter: ObjectFilter,
        maxNumberOfResults: Int = 20
    ) async throws -> [TransitLocation] {
        
        var request = HTTPRequest(
            method: .get,
            path: QueryEndpoints.stopFinder.rawValue
        )
        
        request.queryItems = [
            URLQueryItem(name: "locationServerActive", value: "1"),
            URLQueryItem(name: "anyObjFilter_sf", value: "\(objectFilter.rawValue)"),
            URLQueryItem(name: "name_sf", value: "\(coordinate.longitude):\(coordinate.latitude):WGS84[DD.DDDDD]"),
            URLQueryItem(name: "type_sf", value: "coord"),
            URLQueryItem(name: "anyMaxSizeHitList", value: "\(maxNumberOfResults)"),
            URLQueryItem(name: "coordOutputFormat", value: CoordinateOutputFormat.wgs84.rawValue),
            URLQueryItem(name: "UTFMacro", value: "1"),
        ]
        
        let result = await loader.load(request)
        
        let response = try await result.decodingXML(
            StopFinderResponse.self,
            request: request,
            decoder: Self.defaultDecoder
        )
        
        return response.stopFinderRequest
            .odv
            .assignedStops?
            .stops
            .sorted(by: { $0.distanceTime < $1.distanceTime })
            .map({
                TransitLocation(
                    stationID: $0.stopID,
                    statelessIdentifier: $0.value,
                    locationType: .stop,
                    name: $0.name,
                    description: $0.nameWithPlace,
                    coordinates: $0.coordinates
                )
            }) ?? []
        
    }
    
    // MARK: - Departure Monitor
    
    public func sendRawDepartureMonitorRequest(
        id: Station.ID
    ) async throws -> DepartureMonitorResponse {
        
        var request = HTTPRequest(
            method: .get,
            path: QueryEndpoints.departureMonitor.rawValue
        )
        
        request.queryItems = [
            URLQueryItem(name: "name_dm", value: "\(id)"),
            URLQueryItem(name: "useRealtime", value: "1"),
            URLQueryItem(name: "locationServerActive", value: "1"),
            URLQueryItem(name: "type_dm", value: "stop"),
            URLQueryItem(name: "itdDateTimeDepArr", value: "dep"),
            URLQueryItem(name: "mode", value: "direct"),
            URLQueryItem(name: "coordOutputFormat", value: CoordinateOutputFormat.wgs84.rawValue),
            URLQueryItem(name: "UTFMacro", value: "1")
        ]
        
        let result = await loader.load(request)
        
        return try await result.decodingXML(
            DepartureMonitorResponse.self,
            request: request,
            decoder: Self.defaultDecoder
        )
        
    }
    
    public func departureMonitor(id: Station.ID) async throws -> DepartureMonitorData {
        
        let response = try await sendRawDepartureMonitorRequest(id: id)
        
        let departures = response.departureMonitorRequest.departures
            .departures
            .map { DepartureViewModel(departure: $0) }
        
        let name = response.departureMonitorRequest.odv.name?.elements?.first?.name ?? "Unbekannt"
        
        return DepartureMonitorData(
            date: response.now,
            name: name,
            departures: departures
        )
        
    }
    
    // MARK: - Trip Request -
    
    public func sendTripRequest(
        origin: Stop.ID,
        destination: Stop.ID,
        tripDate: TripDate
    ) async throws -> TripResponse {
        
        return try await sendTripRequest(
            origin: "\(origin)",
            destination: "\(destination)",
            tripDate: tripDate
        )
        
    }
    
    public func sendTripRequest(
        origin: String,
        destination: String,
        config: TripRequest.Configuration = .init(),
        tripDate: TripDate
    ) async throws -> TripResponse {
        
        var request = HTTPRequest(
            method: .get,
            path: QueryEndpoints.trip.rawValue
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_de")
        dateFormatter.dateFormat = "ddMMyyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        
        request.queryItems = [
            URLQueryItem(name: "UTFMacro", value: "1"),
            URLQueryItem(name: "useRealtime", value: "1"),
            URLQueryItem(name: "locationServerActive", value: "1"),
            URLQueryItem(name: "coordOutputFormat", value: CoordinateOutputFormat.wgs84.rawValue),
            URLQueryItem(name: "name_origin", value: "\(origin)"),
            URLQueryItem(name: "name_destination", value: "\(destination)"),
            URLQueryItem(name: "type_origin", value: "any"),
            URLQueryItem(name: "type_destination", value: "any"),
            URLQueryItem(name: "ptOptionsActive", value: "1"),
            URLQueryItem(name: "calcNumberOfTrips", value: "\(config.calcNumberOfTrips)"),
            URLQueryItem(name: "itdDateDayMonthYear", value: dateFormatter.string(from: tripDate.date)),
            URLQueryItem(name: "itdTime", value: timeFormatter.string(from: tripDate.date)),
            URLQueryItem(name: "itdTripDateTimeDepArr", value: tripDate.toRaw().rawValue),
            URLQueryItem(name: "mode", value: "direct"),
        ]
        
        let result = await loader.load(request)
        
        return try await result.decodingXML(
            TripResponse.self,
            request: request,
            decoder: Self.defaultDecoder
        )
        
    }
    
    // MARK: - Geo Object -
    
    public func geoObject(
        lines: [LineIdentifiable]
    ) async throws -> GeoITDRequest {
        
        var request = HTTPRequest(
            method: .get,
            path: QueryEndpoints.geoObject.rawValue
        )
        
        let lineQueryItems = lines
            .map { URLQueryItem(name: "line", value: $0.lineIdentifier) }
        
        request.queryItems = [
            URLQueryItem(name: "UTFMacro", value: "1"),
            URLQueryItem(name: "useRealtime", value: "1"),
            URLQueryItem(name: "locationServerActive", value: "1"),
            URLQueryItem(name: "ptOptionsActive", value: "1"),
            URLQueryItem(name: "coordOutputFormat", value: CoordinateOutputFormat.wgs84.rawValue)
        ] + lineQueryItems
        
        let result = await loader.load(request)
        
        return try await result.decodingXML(
            GeoITDRequest.self,
            request: request,
            decoder: Self.defaultDecoder
        )
        
    }
    
    // MARK: - Helpers
    
    nonisolated(unsafe) public static let defaultDecoder: XMLDecoder = {
        
        let decoder = XMLDecoder()
        let format = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        decoder.dateDecodingStrategy = .formatted(format)
        
        return decoder
        
    }()
    
    public static func defaultLoader() -> HTTPLoader {
        
        let environment = ServerEnvironment(scheme: "https", host: "openservice.vrr.de", pathPrefix: "/vrr")
        
        let resetGuard = ResetGuardLoader()
        let applyEnvironment = ApplyEnvironmentLoader(environment: environment)
        let session = URLSession(configuration: .default)
        let sessionLoader = URLSessionLoader(session)
        let printLoader = PrintLoader()
        
        return (resetGuard --> applyEnvironment --> printLoader --> sessionLoader)!
        
    }
    
}
