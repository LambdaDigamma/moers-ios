//
//  DefaultEFAService.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import XMLCoder
import Combine
import ModernNetworking
import CoreLocation

public class DefaultTransitService: TransitService {
    
    private let languageCode: String
    private let loader: HTTPLoader
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
    ) -> AnyPublisher<StopFinderResponse, HTTPError> {
        
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
        
        return Deferred {
            
            return Future<StopFinderResponse, HTTPError> { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    result.decodingXML(
                        StopFinderResponse.self,
                        decoder: Self.defaultDecoder
                    ) { (result: Result<StopFinderResponse, HTTPError>) in
                        
                        switch result {
                            case .success(let response):
                                promise(.success(response))
                            case .failure(let error):
                                promise(.failure(error))
                        }
                        
                    }
                    
                }
                
            }
            
        }.eraseToAnyPublisher()
        
    }
    
    public func findTransitLocation(
        for searchTerm: String,
        filtering objectFilter: ObjectFilter
    ) -> AnyPublisher<[TransitLocation], HTTPError> {
        
        self.sendRawStopFinderRequest(searchText: searchTerm, objectFilter: objectFilter)
            .map({ (response: StopFinderResponse) in
                return response.stopFinderRequest
                    .odv
                    .name?
                    .elements?
                    .sorted(by: { $0.matchQuality > $1.matchQuality })
                    .map({ TransitLocation(odvNameElement: $0) }) ?? []
            })
            .replaceEmpty(with: [])
            .eraseToAnyPublisher()
        
    }
    
    public func findTransitLocation(
        for coordinate: CLLocationCoordinate2D,
        filtering objectFilter: ObjectFilter,
        maxNumberOfResults: Int = 20
    ) -> AnyPublisher<[TransitLocation], HTTPError> {
        
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
        
        return Deferred {
            
            return Future<StopFinderResponse, HTTPError> { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    result.decodingXML(
                        StopFinderResponse.self,
                        decoder: Self.defaultDecoder
                    ) { (result: Result<StopFinderResponse, HTTPError>) in
                        
                        switch result {
                            case .success(let response):
                                promise(.success(response))
                            case .failure(let error):
                                promise(.failure(error))
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .map({ (response: StopFinderResponse) in
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
        })
        .eraseToAnyPublisher()
        
    }
    
    // MARK: - Departure Monitor
    
    public func sendRawDepartureMonitorRequest(
        id: Station.ID
    ) -> AnyPublisher<DepartureMonitorResponse, HTTPError> {
        
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
        
        return Deferred {
            
            return Future<DepartureMonitorResponse, HTTPError> { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    result.decodingXML(
                        DepartureMonitorResponse.self,
                        decoder: Self.defaultDecoder
                    ) { (result: Result<DepartureMonitorResponse, HTTPError>) in
                        
                        switch result {
                            case .success(let response):
                                promise(.success(response))
                            case .failure(let error):
                                promise(.failure(error))
                        }
                        
                    }
                    
                }
                
            }
            
        }.eraseToAnyPublisher()
        
    }
    
    public func departureMonitor(id: Station.ID) -> AnyPublisher<DepartureMonitorData, Error> {
        
        return sendRawDepartureMonitorRequest(id: id)
            .map { (response: DepartureMonitorResponse) in
                
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
            .mapError({ error in
                return error as Error
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
    // MARK: - Trip Request -
    
    public func sendTripRequest(
        origin: Stop.ID,
        destination: Stop.ID,
        tripDate: TripDate
    ) -> AnyPublisher<TripResponse, HTTPError> {
        
        return sendTripRequest(
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
    ) -> AnyPublisher<TripResponse, HTTPError> {
        
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
        
        return Deferred {
            
            return Future<TripResponse, HTTPError> { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    result.decodingXML(
                        TripResponse.self,
                        decoder: Self.defaultDecoder
                    ) { (result: Result<TripResponse, HTTPError>) in
                        
                        switch result {
                            case .success(let response):
                                promise(.success(response))
                            case .failure(let error):
                                promise(.failure(error))
                        }
                        
                    }
                    
                }
                
            }
            
        }.eraseToAnyPublisher()
        
    }
    
    // MARK: - Geo Object -
    
    public func geoObject(
        lines: [LineIdentifiable]
    ) -> AnyPublisher<GeoITDRequest, HTTPError> {
        
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
        
        return Deferred {
            
            return Future<GeoITDRequest, HTTPError> { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    result.decodingXML(
                        GeoITDRequest.self,
                        decoder: Self.defaultDecoder
                    ) { (result: Result<GeoITDRequest, HTTPError>) in
                        
                        switch result {
                            case .success(let response):
                                promise(.success(response))
                            case .failure(let error):
                                promise(.failure(error))
                        }
                        
                    }
                    
                }
                
            }
            
        }.eraseToAnyPublisher()
        
    }
    
    // MARK: - Helpers
    
    public static let defaultDecoder: XMLDecoder = {
        
        let decoder = XMLDecoder()
        let format = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
//        decoder.
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
