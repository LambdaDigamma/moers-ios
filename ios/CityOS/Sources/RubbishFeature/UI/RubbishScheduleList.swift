//
//  RubbishScheduleList.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import SwiftUI
import Factory
import Core

public struct RubbishScheduleList: View {
    
    @State var showInfo: Bool = false
    @ObservedObject var viewModel: RubbishScheduleViewModel
    
    public init(
        rubbishService: RubbishService? = nil
    ) {
        self.viewModel = RubbishScheduleViewModel()
    }
    
    public var body: some View {
        
        ZStack {
            
            viewModel.state.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
            viewModel.state.hasResource { (sections: [RubbishSection]) in
                
                List {
                    
                    ForEach(sections, id: \.self) { section in
                        
                        Section {
                            
                            ForEach(section.items) { item in
                                
                                RubbishPickupRow(item: item)
                                    .padding(.vertical, 4)
                                
                            }
                            
                        } header: {
                            
                            Text(section.header)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            viewModel.state.hasError { (error: RubbishLoadingError) in
                
                ZStack {
                    
                    Text(error.localizedDescription)
                        .foregroundColor(.primary)
                    
                }
                .padding()
                
            }
            
        }
        .task {
            UserActivity.current = UserActivities.configureRubbishScheduleActivity()
            viewModel.load()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(PackageStrings.WasteSchedule.title)
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showInfo = true
                }, label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.yellow)
                })
            }
        })
        .sheet(isPresented: $showInfo, onDismiss: nil, content: {
            
            info()
            
        })
//        .userActivity(UserActivities.IDs.rubbishSchedule) { (activity: NSUserActivity) in
//            UserActivities.configureRubbishScheduleActivity(for: activity)
//        }
        
    }
    
    @ViewBuilder
    internal func info() -> some View {
        
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(String(localized: "Selected street", bundle: .module).uppercased())
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.accentColor)
                        
                        if let street = viewModel.rubbishService.rubbishStreet {
                            Text(street.displayName)
                                .font(.title3.weight(.semibold))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .padding(.top)
                    
                    Text("""
The waste calendar is provided by waste management company ENNI for the app.
There is no guarantee that the data listed here is correct.
If you have any problems, you should therefore rather contact ENNI itself.
""", bundle: .module)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding([.horizontal])
                    
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showInfo = false
                    }) {
                        Text("Close", bundle: .module)
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
}

struct RubbishScheduleList_Previews: PreviewProvider {
    
    static let street = RubbishCollectionStreet(
        id: 1,
        street: "Musterstraße",
        residualWaste: 0,
        organicWaste: 0,
        paperWaste: 0,
        yellowBag: 0,
        greenWaste: 0,
        sweeperDay: ""
    )
    
    static var previews: some View {
        
        NavigationView {
            RubbishScheduleList(rubbishService: StaticRubbishService())
        }
        .preferredColorScheme(.dark)
        .environment(\.colorScheme, .dark)
        
        RubbishScheduleList(rubbishService: StaticRubbishService(rubbishStreet: street)).info()
        .preferredColorScheme(.dark)
        .environment(\.colorScheme, .dark)
        
    }
    
}
