import XCTest
import Combine
import ModernNetworking
@testable import EFAAPI

final class DefaultServiceMockedTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func test_execute_stop_finder_request_list() {
        
        let expectation = XCTestExpectation()
        
        let loader = FileLoader(resource: "Data/StopFinder_List", fileExtension: "xml")
        let service = DefaultTransitService(loader: loader)
        
        service
            .sendRawStopFinderRequest(searchText: "König")
            .sink { (completion: Subscribers.Completion<HTTPError>) in
                
            } receiveValue: { (response: StopFinderResponse) in
                
                XCTAssertEqual(response.language.count, 2)
                XCTAssertEqual(response.stopFinderRequest.odv.name?.elements?.count, 268)
                
                let expected = ITDDateTime(
                    ttpFrom: "20211101",
                    ttpTo: "20220430",
                    date: ITDDate(
                        weekday: 6,
                        year: 2021,
                        month: 12,
                        day: 10
                    ),
                    time: ITDTime(
                        hour: 0,
                        minute: 31
                    )
                )
                
                XCTAssertEqual(response.stopFinderRequest.dateTime, expected)
                XCTAssertEqual(response.stopFinderRequest.odv.usage, ODVUsageType.sf)
                XCTAssertEqual(response.stopFinderRequest.odv.name?.input?.name, "König")
                
                expectation.fulfill()
            }
            .store(in: &cancellables)

        
        wait(for: [expectation], timeout: 10)
        
    }
    
    func test_execute_stop_finder_request_list_objectfilter() {

        let expectation = XCTestExpectation()

        let loader = FileLoader(resource: "Data/StopFinder_List_ObjectFilter", fileExtension: "xml")
        let service = DefaultTransitService(loader: loader)

        service
            .sendRawStopFinderRequest(searchText: "Duisburg Hbf", objectFilter: [.stops])
            .sink { (completion: Subscribers.Completion<HTTPError>) in

                switch (completion) {
                    case .failure(let error):
                        print(error)
                    default: break
                }

            } receiveValue: { (response: StopFinderResponse) in

                XCTAssertEqual(response.language.count, 2)
                XCTAssertEqual(response.stopFinderRequest.odv.objectFilter, [.stops])
                XCTAssertEqual(response.stopFinderRequest.odv.name?.elements?.count, 3)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

    }
    
    func test_decode_identified_trip_request() throws {
        
        let data = loadData(resource: "Data/TripRequest", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder
        
        let response = try decoder.decode(TripResponse.self, from: data)
        
        XCTAssertEqual(response.sessionID, "EFAOPENSERVICE2_1730994392")
        
//        XCTAssertEqual(response.tripRequest.dateTime.ttpFrom, "20220201")
//        XCTAssertEqual(response.tripRequest.dateTime.ttpTo, "20220831")
        
        print(response)
        
    }
    
    func test_decode_unknown_via_odv() throws {
        
        let data = loadData(resource: "Data/TripODVs", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder
        
        let response = try decoder.decode(ITDRouteList.self, from: data)
        
        print(response)
        
    }
    
    func test_decode_route_list() throws {

        let data = loadData(resource: "Data/RouteList", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder

        let response = try decoder.decode(TripResponse.self, from: data)

        XCTAssertNotNil(response.tripRequest.itinerary.routeList)

        print(response)

    }

    func test_decode_trip_request_1() throws {

        let data = loadData(resource: "Data/TripRequest1", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder

        let response = try decoder.decode(TripResponse.self, from: data)

        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)

        print(response)

    }

//    func test_decode_trip_request_2() throws {
//
//        let data = loadData(resource: "Data/TripRequest2", fileExtension: "xml")
//        let decoder = DefaultTransitService.defaultDecoder
//
//        let response = try decoder.decode(TripResponse.self, from: data)
//
//        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)
//
//        print(response)
//
//    }
    
//    func test_decode_trip_request_3() throws {
//
//        let data = loadData(resource: "Data/TripRequest3", fileExtension: "xml")
//        let decoder = DefaultTransitService.defaultDecoder
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
    
    func test_decode_trip_request_4() throws {
        
        let data = loadData(resource: "Data/TripRequest4", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder
        
        let response = try decoder.decode(TripResponse.self, from: data)
        
        XCTAssertNotNil(response.tripRequest.itinerary.routeList)
//        XCTAssertNotNil(response.tripRequest.odv.first?.assignedStops)
        
        print(response)
        
    }
    
    func test_decode_trip_request_from_street() throws {
        
        let data = loadData(resource: "Data/TripRequestFromStreet", fileExtension: "xml")
        let decoder = DefaultTransitService.defaultDecoder
        
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
    
    static var allTests = [
        ("test_execute_stop_finder_request_list", test_execute_stop_finder_request_list),
        ("test_execute_stop_finder_request_list_objectfilter", test_execute_stop_finder_request_list_objectfilter)
    ]
}
