import XCTest
import ModernNetworking
@testable import EFAAPI

@MainActor
final class DefaultServiceMockedTests: XCTestCase {
    
    
    func test_has_17_query_endpoints() async {
        XCTAssertEqual(QueryEndpoints.allCases.count, 17)
    }

    func test_execute_stop_finder_request_list() async throws {
        let loader = FileLoader(resource: "Data/StopFinder_List", fileExtension: "xml")
        let service = DefaultTransitService(loader: loader)
        let response = try await service.sendRawStopFinderRequest(searchText: "König")
        XCTAssertEqual(response.language.count, 2)
        XCTAssertEqual(response.stopFinderRequest.odv.name?.elements?.count, 268)
        let expected = ITDDateTime(
            ttpFrom: "20211101", ttpTo: "20220430",
            date: ITDDate(weekday: 6, year: 2021, month: 12, day: 10),
            time: ITDTime(hour: 0, minute: 31)
        )
        XCTAssertEqual(response.stopFinderRequest.dateTime, expected)
        XCTAssertEqual(response.stopFinderRequest.odv.usage, ODVUsageType.sf)
        XCTAssertEqual(response.stopFinderRequest.odv.name?.input?.name, "König")
    }

    func test_execute_stop_finder_request_list_objectfilter() async throws {
        let loader = FileLoader(resource: "Data/StopFinder_List_ObjectFilter", fileExtension: "xml")
        let service = DefaultTransitService(loader: loader)
        let response = try await service.sendRawStopFinderRequest(searchText: "Duisburg Hbf", objectFilter: [.stops])
        XCTAssertEqual(response.language.count, 2)
        XCTAssertEqual(response.stopFinderRequest.odv.objectFilter, [.stops])
        XCTAssertEqual(response.stopFinderRequest.odv.name?.elements?.count, 3)
    }

    func test_decode_identified_trip_request() async throws {
        
        let data = loadData(resource: "Data/TripRequest", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder()
        
        let response = try decoder.decode(TripResponse.self, from: data)
        
        XCTAssertEqual(response.sessionID, "EFAOPENSERVICE2_1730994392")
        
//        XCTAssertEqual(response.tripRequest.dateTime.ttpFrom, "20220201")
//        XCTAssertEqual(response.tripRequest.dateTime.ttpTo, "20220831")
        
        print(response)
        
    }
    
    func test_decode_unknown_via_odv() async throws {
        
        let data = loadData(resource: "Data/TripODVs", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder()
        
        let response = try decoder.decode(ITDRouteList.self, from: data)
        
        print(response)
        
    }
    
    func test_decode_route_list() async throws {

        let data = loadData(resource: "Data/RouteList", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder()

        let response = try decoder.decode(TripResponse.self, from: data)

        XCTAssertNotNil(response.tripRequest.itinerary.routeList)

        print(response)

    }

    func test_decode_trip_request_1() async throws {

        let data = loadData(resource: "Data/TripRequest1", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder()

        let response = try decoder.decode(TripResponse.self, from: data)

        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)

        print(response)

    }

//    func test_decode_trip_request_2() async throws {
//
//        let data = loadData(resource: "Data/TripRequest2", fileExtension: "xml")
//        let decoder = DefaultTransitService.defaultDecoder()
//
//        let response = try decoder.decode(TripResponse.self, from: data)
//
//        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)
//
//        print(response)
//
//    }
    
//    func test_decode_trip_request_3() async throws {
//
//        let data = loadData(resource: "Data/TripRequest3", fileExtension: "xml")
//        let decoder = DefaultTransitService.defaultDecoder()
//
//        do {
//
//            let response = try decoder.decode(TripResponse.self, from: data)
//
//            //        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//            //        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)
//
//            print(response)
//
//        } catch {
//
//            print(error)
//
//            let err = error as NSError
//            print(err.helpAnchor)
//            print(err.localizedFailureReason)
////            print(err.underlyingErrors)
//
//        }
//
//    }
    
    func test_decode_trip_request_4() async throws {
        
        let data = loadData(resource: "Data/TripRequest4", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder()
        
        let response = try decoder.decode(TripResponse.self, from: data)
        
        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)
        
        print(response)
        
    }
    
    func test_decode_trip_request_from_street() async throws {
        
        let data = loadData(resource: "Data/TripRequestFromStreet", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder()
        
        let response = try decoder.decode(TripResponse.self, from: data)
        
        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)
        
        print(response)
        
    }
    
    func loadData(resource: String, fileExtension: String) -> Data {
        
        if let path = Bundle.module.path(forResource: resource, ofType: fileExtension) {
            
            do {
                
                let content = try String(contentsOfFile: path)
//                let sanitized = content.replacingOccurrences(of: "&", with: "&#38;")
                
                return content.data(using: .utf8) ?? Data()
                
            } catch {
                print(error)
            }
            
        }
        
        return Data()
        
    }
    
}
