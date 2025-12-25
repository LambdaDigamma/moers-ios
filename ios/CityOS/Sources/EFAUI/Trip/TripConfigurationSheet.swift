//
//  TripConfigurationSheet.swift
//  
//
//  Created by Lennart Fischer on 08.04.22.
//

import SwiftUI
import EFAAPI

public struct TripConfigurationSheet: View {
    
    @State var timeMode: TripDateTimeType = .departure
    @State var searchDate: Date = Date()
    
    @State var routeType: RouteType = .leastTime
    @State var changeSpeed: ChangeSpeed = .normal
    
    @Environment(\.accent) var accentColor
    
    public var body: some View {
        
        NavigationView {
            
            Form {
                Section(header: Text("Zeitpunkt")) {
                    
                    VStack {
                        
                        Picker(selection: $timeMode) {
                            ForEach(TripDateTimeType.allCases, id: \.self) { mode in
                                Text(mode.name)
                                    .tag(mode)
                            }
                        } label: {
                            Text("fjsdf")
                        }
                        .foregroundColor(.white)
                        .pickerStyle(.segmented)
                        
                        DatePicker("Abfahrtszeit", selection: $searchDate)
                            .labelsHidden()
                        
                    }
                }
                
                Section(header: Text("Verkehrsmittel")) {
                    ForEach(TransportType.allCases) { type in
                        Text(type.localizedName)
                    }
                }
                
                Section(header: Text("Routentyp")) {
                    Picker(selection: $routeType) {
                        ForEach(RouteType.allCases, id: \.self) { mode in
                            Text(mode.localizedName)
                                .tag(mode)
                                .frame(maxWidth: .infinity)
                        }
                    } label: {
                        Text("Routentyp")
                    }
                    .foregroundColor(.white)
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Umsteigezeit")) {
                    Picker(selection: $changeSpeed) {
                        ForEach(ChangeSpeed.allCases, id: \.self) { mode in
                            Text(mode.localizedName)
                                .tag(mode)
                                .frame(maxWidth: .infinity)
                        }
                    } label: {
                        Text("Umsteigezeit")
                    }
                    .foregroundColor(.white)
                    .pickerStyle(.menu)
                    
                }
                
            }
            
//            ScrollView {
                
//                LazyVStack {
//
//                    Divider()
//
//                    if #available(iOS 15.0, *) {
//
//                        DatePicker(selection: $searchDate, displayedComponents: [.date, .hourAndMinute]) {
//
//                            Picker(selection: $timeMode) {
//                                ForEach(TripConfigurationTimeMode.allCases, id: \.self) { mode in
//                                    Text(mode.name)
//                                        .tag(mode)
//                                }
//                            } label: {
//                                Text("fjsdf")
//                            }
//                            .foregroundColor(.white)
//                            .pickerStyle(.segmented)
//
//                        }
//
//                        DatePicker("Abfahrtszeit", selection: $searchDate)
//                            .datePickerStyle(.automatic)
//                            .accentColor(accentColor)
//                            .tint(accentColor)
//                    }
//
//                    Divider()
//
//                }
//                .padding()
                
//            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Suchoptionen ändern")
            
        }
        
    }
    
}

struct TripConfigurationSheet_Previews: PreviewProvider {
    static var previews: some View {
        
        TripConfigurationSheet()
            .efaAccentColor(.yellow)
            .preferredColorScheme(.dark)
        
    }
}
