//
//  RadioBroadcastViewModelTest.swift
//  
//
//  Created by Lennart Fischer on 01.10.21.
//

import Foundation
import XCTest
@testable import Core

final class RadioBroadcastViewModelTest: XCTestCase {
    
    func testInitPlain() {
        
        let viewModel = RadioBroadcastViewModel(
            id: 1,
            title: "The Greatest Hits from Moers",
            subtitle: "Fr, 01.09. 10:00 - 12:00",
            imageURL: "https://picsum.photos/200"
        )
        
        XCTAssertEqual(viewModel.title, "The Greatest Hits from Moers")
        XCTAssertEqual(viewModel.subtitle, "Fr, 01.09. 10:00 - 12:00")
        XCTAssertEqual(viewModel.imageURL, "https://picsum.photos/200")
        
    }
    
    func testInitFromBroadcast() {
        
        var broadcast = RadioBroadcast(id: 1, uid: .init(), title: "What's up?!")
        
        broadcast.startsAt = Date.stub(from: "2021-09-10 18:04:00")
        broadcast.endsAt = Date.stub(from: "2021-09-10 19:24:00")
        broadcast.attach = "https://picsum.photos/200"
        
        let viewModel = RadioBroadcastViewModel(from: broadcast)
        
        XCTAssertEqual(viewModel.title, "What's up?!")
//        XCTAssertEqual(viewModel.subtitle, "9/10/21, 6:04 – 7:24 PM")
        XCTAssertEqual(viewModel.imageURL, "https://picsum.photos/200")
        
    }
    
}
