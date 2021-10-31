//
//  BroadcastDetail.swift
//  
//
//  Created by Lennart Fischer on 24.09.21.
//

import SwiftUI
import Nuke
import NukeUI

public struct BroadcastDetail: View {
    
    @ObservedObject private var viewModel: RadioBroadcastViewModel
    
    private let listenNowAction: () -> Void
    private let toggleReminderAction: () -> Void
    
    public init(
        viewModel: RadioBroadcastViewModel,
        listenNowAction: @escaping () -> Void,
        toggleReminderAction: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.listenNowAction = listenNowAction
        self.toggleReminderAction = toggleReminderAction
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading) {
                
                header()
                    .padding()
                
                information()
                
                actions()
                    .padding()
                    .padding(.bottom)
                
//                recommendations()
                
            }
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.yellow)
                })
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        ZStack {
            
            if let imageURL = viewModel.imageURL {
                LazyImage(source: imageURL)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 200)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.tertiarySystemFill))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 100, maxHeight: 100)
            }
            
        }
        .frame(maxWidth: 200, maxHeight: 200)
        .cornerRadius(8)
        
    }
    
    @ViewBuilder
    private func information() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.title)
                .font(.title2.weight(.bold))
            
            Text(viewModel.subtitle)
                .fontWeight(.medium)
            
            if let description = viewModel.description {
                
                Text(description)
                    .font(.callout)
                    .foregroundColor(.secondary)
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
//            Button(action: listenNowAction) {
//                Text(AppStrings.Buergerfunk.listenNowAction)
//            }
//            .buttonStyle(PrimaryButtonStyle())
            
            Button(action: {
                withAnimation {
                    self.viewModel.enabledReminder.toggle()
                    print("Enabled reminder: \(self.viewModel.enabledReminder)")
                }
                toggleReminderAction()
            }) {
                
                if !viewModel.enabledReminder {
                    Text("\(Image(systemName: "bell.circle.fill")) \(AppStrings.Buergerfunk.remindMeAction)")
                } else {
                    Text("\(Image(systemName: "bell.slash.circle.fill")) \(AppStrings.Buergerfunk.reminderActiveAction)")
                }
                
            }
            .buttonStyle(SecondaryButtonStyle())
            
            if viewModel.enabledReminder {
                
                Text(AppStrings.Buergerfunk.disableReminderInfo)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func recommendations() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Weitere Sendungen")
                .fontWeight(.bold)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                
            }
            
            Divider()
            
            Text("Ortsgespräche Rheinberg")
                .font(.body)
            
        }
        .padding()
        .ignoresSafeArea(.container, edges: .bottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        
    }
    
}

struct BroadcastDetail_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = RadioBroadcastViewModel(
            id: 1,
            title: "What's up?!",
            subtitle: "9/10/21, 6:04 – 7:24 PM",
            imageURL: "http://www.buergerfunk-moers.de/wp-content/uploads/2021/08/Bild_2021-08-24_221932-e1630172834136.png",
            description: "Lorem ipsum…"
        )
        
        NavigationView {
            BroadcastDetail(
                viewModel: viewModel,
                listenNowAction: {},
                toggleReminderAction: {}
            )
        }.preferredColorScheme(.dark)
        
    }
}
