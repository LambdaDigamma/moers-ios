//
//  RubbishDashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMAPI
import ModernNetworking

enum RubbishDisplayError: Error {
    
    case loadingFailed
    case noUpcomingRubbishItems
    case wasteScheduleDeactivated
    
}

extension RubbishDisplayError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            case .noUpcomingRubbishItems:
                return "Leider können momentan keine weiteren Abholtermine angezeigt werden, da die Daten für dieses Jahr noch nicht zur Verfügung stehen. Wir arbeiten daran, so schnell wie möglich aktuelle Termine bereitstellen zu können!"
            case .loadingFailed:
                return AppStrings.Waste.loadingFailed
                
            case .wasteScheduleDeactivated:
                return AppStrings.Waste.errorMessage
        }
    }
    
}

struct RubbishDashboardPanel: View {
    
    var items: UIResource<[RubbishPickupItem]>
    
    init(items: UIResource<[RubbishPickupItem]> = .loading) {
        self.items = items
    }
    
    var body: some View {
        CardPanelView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                items.isLoading {
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            LoadingIndicator(style: .medium)
                            Text("Lädt Abfallkalender...")
                                .fontWeight(.semibold)
                                .font(.callout)
                        }
                        Spacer()
                    }.padding()
                    
                }
                
                items.hasResource { (items) in
                    
                    HStack {
                        Text("DashboardTitleRubbishCollection")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.horizontal, 20)
                    
                    if !items.isEmpty {
                        
                        ForEach(items, id: \.id) { (item) in
                            
                            HStack(alignment: .center) {
                                
                                RubbishTypeIcon(type: item.type)
                                    .frame(width: 50)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(RubbishWasteType.localizedForCase(item.type))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text(DateFormatter.localizedString(
                                            from: item.date,
                                            dateStyle: .full,
                                            timeStyle: .none)
                                    )
                                        .font(.callout)
                                }
                                
                            }
                            .padding(.all, 12)
                            
                        }
                        
                    } else {
                        
                        VStack {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark").font(.largeTitle)
                                Text("There are no other known collection dates.")
                            }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        
                    }
                    
                }
                
                items.hasError { error in
                    
                    if let error = error as? RubbishDisplayError {
                        if error == .wasteScheduleDeactivated {
                            VStack {
                                Text(error.localizedDescription)
                                    .fontWeight(.semibold)
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }.padding()
                        }
                    }
                    
                }
                
            }
            
        }
        .padding()
    }
    
}

struct PetrolDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            RubbishDashboardPanel()
                .environment(\.locale, .init(identifier: "de"))
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel()
                .environment(\.locale, .init(identifier: "de"))
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .success([RubbishPickupItem(date: .init(timeIntervalSinceNow: 86400),
                                                                    type: .paper),
                                                  RubbishPickupItem(date: .init(timeIntervalSinceNow: 86400 * 2),
                                                                    type: .organic),
                                                  RubbishPickupItem(date: .init(timeIntervalSinceNow: 86400 * 3),
                                                                    type: .plastic)]))
                .environment(\.locale, .init(identifier: "de"))
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .success([RubbishPickupItem(date: .init(timeIntervalSinceNow: 86400),
                                                                    type: .paper),
                                                  RubbishPickupItem(date: .init(timeIntervalSinceNow: 86400 * 2),
                                                                    type: .organic),
                                                  RubbishPickupItem(date: .init(timeIntervalSinceNow: 86400 * 3),
                                                                    type: .plastic)]))
                .environment(\.locale, .init(identifier: "de"))
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .error(RubbishDisplayError.wasteScheduleDeactivated))
                .environment(\.locale, .init(identifier: "de"))
                .previewLayout(.sizeThatFits)
            
//            RubbishDashboardView()
//                .environment(\.locale, .init(identifier: "de"))
//                .preferredColorScheme(.dark)
//                .previewLayout(.sizeThatFits)
            
        }
    }
}
