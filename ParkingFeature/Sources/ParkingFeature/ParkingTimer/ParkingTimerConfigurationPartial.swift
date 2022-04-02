//
//  ParkingTimerConfigurationPartial.swift
//  
//
//  Created by Lennart Fischer on 02.04.22.
//

import SwiftUI
import Core
import CoreLocation

public struct ParkingTimerConfigurationPartial: View {
    
    @ObservedObject var viewModel: ParkingTimerViewModel
    
    public init(viewModel: ParkingTimerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView {
                
                LazyVStack {
                    
                    compactPreview()
                        .padding(.bottom)
                    
                    options()
                    
                }.padding()
                
            }
            
            Divider()
            
            actions()
                .padding()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
    }
    
    private let cornerRadius: Double = 12
    
    @ViewBuilder
    private func compactPreview() -> some View {
        
        VStack {
            
            sectionHeader(text: "Überblick")
            
            HStack {
                
                VStack {
                    
                    if let time = ParkingTimerScreen
                        .timeIntervalFormatter.string(from: viewModel.time) {
                        Text("\(time)")
                            .font(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding()
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(cornerRadius)
                
                VStack {
                    
                    Button(action: { withAnimation { viewModel.enableNotifications.toggle() } }) {
                        
                        let imageName = viewModel.enableNotifications ? "bell.fill" : "bell.slash.fill"
                        //                    let imageName = viewModel.enableNotifications ? "app.badge" : "app.badge"
                        
                        Image(systemName: imageName)
                            .foregroundColor(
                                viewModel.enableNotifications ? Color.yellow : Color.secondary
                                //                            viewModel.enableNotifications ? Color.red : Color.secondary
                            )
                            .font(.title)
                            .padding()
                        
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(cornerRadius)
                    
                }
                .frame(maxWidth: 120)
                
            }
            
            locationRow()
            
        }
        
    }
    
    @ViewBuilder
    private func locationRow() -> some View {
        
        HStack(spacing: 0) {
            
            Button(action: { withAnimation { viewModel.saveParkingLocation.toggle() } }) {
                
                let imageName = viewModel.saveParkingLocation ? "mappin" : "mappin.slash"
                
                Image(systemName: imageName)
                    .foregroundColor(
                        viewModel.saveParkingLocation ? Color.red : Color.secondary
                    )
                    .font(.title)
                    .padding()
                
            }
            .frame(maxWidth: 100)
            
            ZStack {
                
                let coordinate = viewModel.carPosition ?? CLLocationCoordinate2D(latitude: 51.45163, longitude: 6.61804)
                
                MapSnapshotView(
                    location: coordinate,
                    span: 0.002
                )
                .opacity(viewModel.saveParkingLocation ? 1 : 0.5)
                
            }
            
        }
        .frame(maxWidth: .infinity, idealHeight: 80)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(cornerRadius)
        
    }
    
    @ViewBuilder
    private func options() -> some View {
        
        sectionHeader(text: "Optionen")
        
        VStack(spacing: 8) {
            
            Toggle(isOn: $viewModel.enableNotifications) {
                Text("Benachrichtungen einschalten")
            }
            
            //            Divider()
            
            Toggle(isOn: $viewModel.saveParkingLocation) {
                Text("Parkort speichern")
            }
            
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(cornerRadius)
        
    }
    
    @ViewBuilder
    private func sectionHeader(text: String) -> some View {
        
        Text(text)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        HStack(spacing: 12) {
            
            buildStepperButton()
            
            Button("Starten", action: viewModel.startTimer)
                .frame(maxHeight: 24)
                .buttonStyle(PrimaryButtonStyle())
            
        }
        
    }
    
    @ViewBuilder
    private func buildStepperButton() -> some View {
        
        let maxWidth: Double = 50
        let innerMaxHeight: Double = 24
        
        HStack {
            
            Button(action: {
                let successful = viewModel.decrementTime()
                let impact = UIImpactFeedbackGenerator(style: successful ? .medium : .light)
                impact.impactOccurred()
            }) {
                Image(systemName: "minus")
                    .frame(maxHeight: innerMaxHeight)
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(viewModel.decrementDisabled)
            .frame(maxWidth: maxWidth)
            
            Button(action: {
                let successful = viewModel.incrementTime()
                let impact = UIImpactFeedbackGenerator(style: successful ? .medium : .light)
                impact.impactOccurred()
            }) {
                Image(systemName: "plus")
                    .frame(maxHeight: innerMaxHeight)
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(viewModel.incrementDisabled)
            .frame(maxWidth: maxWidth)
            
        }
        
    }
    
}
