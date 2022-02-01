//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import SwiftUI
import Core
import Combine

public struct FuelStationDetail: View {
    
    @StateObject var viewModel: FuelStationDetailViewModel
    
    public init(load: @escaping () -> AnyPublisher<PetrolStation, Error>) {
        
        self._viewModel = .init(wrappedValue: FuelStationDetailViewModel(loadDetails: load))
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack(alignment: .leading) {
                
                viewModel.state.hasResource { fuelStation in
                    
                    Text(fuelStation.name)
                        .fontWeight(.semibold)
                    
                    Text(fuelStation.brand)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            Text("Diesel")
                            Spacer()
                            
                            if let diesel = fuelStation.diesel {
                                Text(String(format: "%.2f€", diesel))
                                + Text(" / L")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("/")
                            }
                            
                        }
                        HStack {
                            Text("E5")
                            Spacer()
                            
                            if let priceE5 = fuelStation.e5 {
                                Text(String(format: "%.2f€", priceE5))
                                + Text(" / L")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("/")
                            }
                        }
                        HStack {
                            Text("E10")
                            Spacer()
                            
                            if let e10 = fuelStation.e10 {
                                Text(String(format: "%.2f€", e10))
                                + Text(" / L")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("/")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    DetailContainer(title: "Adresse") {
                        
                        VStack(alignment: .leading) {
                            Text("\(fuelStation.street) \(fuelStation.houseNumber ?? "")")
                            Text("\(fuelStation.place)")
                            
                            GetDirectionsButton(action: {}, travelTime: 4 * 60)
                            
                        }
                        
                    }
                    
                    Divider()
                    
                    if let times = fuelStation.openingTimes {
                        
                        let new = times.map {
                            OpeningHourEntry(
                                text: $0.text,
                                time: "\($0.start) - \($0.end)"
                            )
                        }
                        
                        OpeningHoursContainer(
                            openingHours: new
                        )
                        
                    }
                    
                }
                
            }
            .padding()
            
        }
        .onAppear {
            viewModel.load()
        }
        
    }
    
}

struct FuelStationDetail_Previews: PreviewProvider {
    
    static let fuelStation = PetrolStation.stub(withID: "1")
        .setting(\.name, to: "Aral Tankstelle")
        .setting(\.brand, to: "Aral")
        .setting(\.diesel, to: 1.65)
        .setting(\.e5, to: 1.54)
        .setting(\.e10, to: 1.62)
        .setting(\.houseNumber, to: "23")
        .setting(\.place, to: "Moers")
        .setting(\.postCode, to: 47441)
        .setting(\.openingTimes, to: [
            .init(text: "Mo-Fr", start: "06:00:00", end: "22:30:00"),
            .init(text: "Samstag", start: "07:00:00", end: "22:00:00"),
            .init(text: "Sonntag", start: "08:00:00", end: "22:00:00"),
        ])
    
    static var previews: some View {
        FuelStationDetail(
            load: {
                Just(Self.fuelStation)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .preferredColorScheme(.dark)
    }
    
}
