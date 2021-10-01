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
    
    private let title: String
    private let description: String?
    private var imageURL: String? = nil
    public let startDate: Date?
    public let endDate: Date?
    private let listenNowAction: () -> Void
    private let createReminderAction: () -> Void
    
    public init(
        imageURL: String? = nil,
        listenNowAction: @escaping () -> Void,
        createReminderAction: @escaping () -> Void
    ) {
        self.title = "Platzhalter"
        self.description = nil
        self.imageURL = imageURL
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
        self.imageURL = broadcast.attach
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
            
            if let imageURL = imageURL {
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
            
//            Button(action: listenNowAction) {
//                Text(AppStrings.Buergerfunk.listenNowAction)
//            }
//            .buttonStyle(PrimaryButtonStyle())
            
            Button(action: createReminderAction) {
                Text("\(Image(systemName: "bell.circle.fill")) \(AppStrings.Buergerfunk.remindMeAction)")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Text("Tippe erneut, um die Erinnerung wieder zu löschen.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
                imageURL: "http://www.buergerfunk-moers.de/wp-content/uploads/2021/08/Bild_2021-08-24_221932-e1630172834136.png",
                listenNowAction: {},
                createReminderAction: {}
            )
        }.preferredColorScheme(.dark)
    }
}
