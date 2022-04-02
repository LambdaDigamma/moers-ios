//
//  ParkingTimerScreen.swift
//  
//
//  Created by Lennart Fischer on 02.04.22.
//

import SwiftUI
import Core
import CoreLocation
import Resolver

public struct ParkingTimerScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = ParkingTimerViewModel.loadCurrentOrNew()
    
    public var body: some View {
        
        ZStack {
            
            if viewModel.timerStarted {
                ParkingTimerActivePartial(viewModel: viewModel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                ParkingTimerConfigurationPartial(viewModel: viewModel)
            }
            
        }
        .navigationTitle(Text("Parkuhr"))
        
    }
    
    public static let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    
}

struct ParkingTimerScreen_Previews: PreviewProvider {
    
    static let viewModel: ParkingTimerViewModel = {
        let viewModel = ParkingTimerViewModel()
        viewModel.carPosition = CLLocationCoordinate2D(
            latitude: 51.45339,
            longitude: 6.63140
        )
        return viewModel
    }()
    
    static var previews: some View {
        
//        Resolver.register { StaticLocationService() as LocationService }
        
        NavigationView {
            ParkingTimerScreen()
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
        }
        
        NavigationView {
            ParkingTimerActivePartial(viewModel: Self.viewModel, onCancel: {})
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
        }
        
        NavigationView {
            ParkingTimerScreen()
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
}
