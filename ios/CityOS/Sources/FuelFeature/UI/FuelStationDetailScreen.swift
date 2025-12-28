//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import SwiftUI
import Core
import Combine
import Factory

public struct FuelStationDetailScreen: View {
    
    @StateObject var viewModel: FuelStationDetailViewModel
    
    public init(load: @escaping () -> AnyPublisher<PetrolStation, Error>) {
        
        self._viewModel = .init(wrappedValue: FuelStationDetailViewModel(loadDetails: load))
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack(alignment: .leading) {
                
                viewModel.state.hasResource { fuelStation in
                    
                    FuelStationDetailContent(fuelStation: fuelStation)
                    
                }
                
            }
            .padding()
            
        }
        .task {
            viewModel.load()
        }
        
    }
    
}

public struct FuelStationDetailContent: View {
    
    private let fuelStation: PetrolStation
    
    public init(
        fuelStation: PetrolStation
    ) {
        self.fuelStation = fuelStation
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top, spacing: 8) {
                
                VStack(alignment: .leading) {
                    
                    Text(fuelStation.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(fuelStation.brand)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                }
                
                Spacer()
                
                OpenBadge(isOpen: fuelStation.isOpen)
                
            }
            
            HStack {
                
                if let diesel = fuelStation.diesel {
                    priceCard(type: .diesel, price: diesel)
                }
                
                if let priceE5 = fuelStation.e5 {
                    priceCard(type: .e5, price: priceE5)
                }
                
                if let priceE10 = fuelStation.e10 {
                    priceCard(type: .e10, price: priceE10)
                }
                
            }
            
            Spacer()
                .frame(height: 4)
            
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
            
            Divider()
            
            let address = AddressUiState(
                street: fuelStation.street,
                houseNumber: fuelStation.houseNumber ?? "",
                place: fuelStation.place,
                postcode: fuelStation.postCode != nil ? "\(fuelStation.postCode ?? 0)" : ""
            )
            
            AddressContainer(address: address)
            
            AutoCalculatingDirectionsButton(
                coordinate: fuelStation.coordinate,
                action: {
                    AppleNavigationProvider()
                        .startNavigation(to: fuelStation.coordinate.toPoint(), withName: fuelStation.name)
                }
            )
            
            Text("Datasource: MTS-K via https://creativecommons.tankerkoenig.de - CC BY 4.0", bundle: .module)
                .foregroundColor(.secondary)
                .font(.caption)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func priceCard(type: PetrolType, price: Double) -> some View {
        
        CardPanelView {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(type.name)
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.secondary)
                
                Group {
                    
                    Text(String(format: "%.2f€", price)) +
                    Text(" / L")
                        .foregroundColor(.secondary)
                        .font(.caption.weight(.semibold))
                    
                }
                .font(.title3.weight(.semibold))
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            
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
        FuelStationDetailScreen(
            load: {
                Just(Self.fuelStation)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .preferredColorScheme(.dark)
    }
    
}
