//
//  BroadcastDetail.swift
//  
//
//  Created by Lennart Fischer on 24.09.21.
//

import SwiftUI

public struct BroadcastDetail: View {
    
    private let title: String
    private let description: String?
    public let startDate: Date?
    public let endDate: Date?
    private let listenNowAction: () -> Void
    private let createReminderAction: () -> Void
    
    public init(
        listenNowAction: @escaping () -> Void,
        createReminderAction: @escaping () -> Void
    ) {
        self.title = "Platzhalter"
        self.description = nil
        self.startDate = Date()
        self.endDate = Date(timeIntervalSinceNow: 60 * 60)
        self.listenNowAction = listenNowAction
        self.createReminderAction = createReminderAction
    }
    
    public init(
        broadcast: RadioBroadcast,
        listenNowAction: @escaping () -> Void,
        createReminderAction: @escaping () -> Void
    ) {
        self.title = broadcast.title
        self.description = broadcast.description
        self.startDate = broadcast.startsAt
        self.endDate = broadcast.endsAt
        self.listenNowAction = listenNowAction
        self.createReminderAction = createReminderAction
    }
    
    private var subtitle: String {
        
        if let startDate = startDate, let endDate = endDate {
            return BroadcastRow.intervalFormatter.string(from: startDate, to: endDate)
        } else {
            return "Uhrzeit nicht bekannt"
        }
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading) {
                
                header()
                    .padding(.bottom)
                
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
        
        Rectangle()
            .fill(Color(UIColor.secondarySystemBackground))
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
        
    }
    
    @ViewBuilder
    private func information() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.title2.weight(.bold))
            
            Text(subtitle)
                .fontWeight(.medium)
            
            if let description = description {
                
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
            
            Button(action: listenNowAction) {
                Text(AppStrings.Buergerfunk.listenNowAction)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button(action: createReminderAction) {
                Text("\(Image(systemName: "bell.circle.fill")) \(AppStrings.Buergerfunk.remindMeAction)")
            }
            .buttonStyle(SecondaryButtonStyle())
            
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
        NavigationView {
            BroadcastDetail(
                listenNowAction: {},
                createReminderAction: {}
            )
        }.preferredColorScheme(.dark)
    }
}
