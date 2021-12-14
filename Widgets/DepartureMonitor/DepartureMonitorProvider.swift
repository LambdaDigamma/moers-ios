//
//  DepartureMonitorProvider.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation

import WidgetKit
import SwiftUI
import Combine
import EFAAPI
import ModernNetworking

final class DepartureMonitorProvider: IntentTimelineProvider {
    
    typealias Entry = DepartureMonitorEntry
    typealias Intent = SelectDepartureMonitorStopIntent
    
    var cancellable: AnyCancellable?
    
    private let transitService: DefaultTransitService
    
    public init() {
        
        let serverEnvironment = ServerEnvironment(scheme: "https", host: "openservice.vrr.de", pathPrefix: "vrr")
        let serverEnvironmentLoader = ApplyEnvironmentLoader(environment: serverEnvironment)
        let loader = URLSessionLoader()
        transitService = DefaultTransitService(loader: (serverEnvironmentLoader --> loader)!)
        
    }
    
    // MARK: - UI
    
    func placeholder(in context: Context) -> DepartureMonitorEntry {
        DepartureMonitorEntry(date: Date(), departures: [])
    }
    
    func getSnapshot(
        for configuration: SelectDepartureMonitorStopIntent,
        in context: Context,
        completion: @escaping (DepartureMonitorEntry) -> Void
    ) {
        
        let entry = DepartureMonitorEntry(date: Date(), departures: [
            .init(departure: .stub()),
            .init(departure: .stub()),
            .init(departure: .stub())
        ])
        completion(entry)
        
    }
    
    func getTimeline(
        for configuration: SelectDepartureMonitorStopIntent,
        in context: Context,
        completion: @escaping (Timeline<DepartureMonitorEntry>) -> Void
    ) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        print("Transit station: \(configuration.transitStation?.identifier ?? "") \(configuration.transitStation?.displayString ?? "")")
        
        if let transitStation = configuration.transitStation, let identifier = transitStation.identifier, let stationID = Int(identifier) {
            
            cancellable = DepartureMonitorLoader().fetch(station: stationID) // 20016032
                .sink { (_: Subscribers.Completion<HTTPError>) in
                    
                } receiveValue: { (response: DepartureMonitorResponse) in
                    
                    let departures = response.departureMonitorRequest.departures
                        .departures
                        .map { DepartureViewModel(departure: $0) }
                    
                    let name = response.departureMonitorRequest.odv.name?.elements?.first?.name ?? "Unbekannt"
                    
                    let entry = DepartureMonitorEntry(date: response.now, name: name, departures: departures)
                    
                    let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                    completion(timeline)
                    
                }
            
        } else {
            
        }
        
    }
    
}
