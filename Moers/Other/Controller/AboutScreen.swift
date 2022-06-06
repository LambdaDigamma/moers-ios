//
//  AboutScreen.swift
//  Moers
//
//  Created by Lennart Fischer on 29.05.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMUI
import Core

public enum DeveloperLinkType {
    case website
    case twitter
    case instagram
}

public struct AboutScreen: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public let onOpenReview: () -> Void
    public let onOpenDeveloperLink: (DeveloperLinkType) -> Void
    public let versionString: String
    
    public init(
        onOpenReview: @escaping () -> Void,
        onOpenDeveloperLink: @escaping (DeveloperLinkType) -> Void
    ) {
        self.onOpenReview = onOpenReview
        self.onOpenDeveloperLink = onOpenDeveloperLink
        self.versionString = Bundle.main.versionString
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                VStack(spacing: 20) {
                    
                    Image("MoersAppIcon")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 150)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
                        .padding(.top)
                        
                    
                    VStack(spacing: 4) {
                        
                        Text("Mein Moers")
                            .font(.title.weight(.bold))
                        
                        Text(versionString)
                            .foregroundColor(.secondaryLabel)
                        
                    }
                    
                    Divider().padding(.horizontal)
                    
                    text()
                    
                    Divider().padding(.horizontal)
                    
                    actions()
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.systemBackground)
                
                developer()
                
                wallOfFame()
                
            }
            
        }
        .navigationTitle(Text("Über"))
        .navigationBarTitleDisplayMode(.large)
        
    }
    
    @ViewBuilder
    private func socialLink(text: String, image: Image, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                image
                    .frame(width: 20, height: 20)
                Text(text)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(8)
        }
        
    }
    
    @ViewBuilder
    private func text() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Diese App wird seit 2016 von Lennart Fischer ehrenamtlich entwickelt und gepflegt. Alle Daten, die in dieser App verwendet werden, sind als sogenannte Offene Daten verfügbar und tragen somit dazu bei, dass es diese App gibt. Falls Du Ideen für neue Funktionen hast, dann schreib mir gerne ein Feedback. Außerdem freue ich mich über eine (gute) Bewertung im App Store.")
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        VStack {
            
            Button("App bewerten", action: onOpenReview)
                .buttonStyle(PrimaryButtonStyle())
                .accessibility(identifier: "About.rateButton")
            
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    @ViewBuilder
    private func developer() -> some View {
        
        VStack {
            
            HStack(spacing: 20) {
                
                Circle()
                    .fill(Color.clear)
                    .background(Image("avatar").resizable())
                    .clipShape(Circle())
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading) {
                    
                    Text("Lennart Fischer")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Software-Entwickler")
                        .foregroundColor(.secondaryLabel)
                    
                }
                
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                
                socialLink(
                    text: "Webseite",
                    image: Image(systemName: "link"),
                    action: { onOpenDeveloperLink(.website) }
                )
                socialLink(
                    text: "Twitter",
                    image: Image("twitter-fill"),
                    action: { onOpenDeveloperLink(.twitter) }
                )
                socialLink(
                    text: "Instagram",
                    image: Image("instagram-fill"),
                    action: { onOpenDeveloperLink(.instagram) }
                )
                
            }
            .foregroundColor(colorScheme == .light ? .blue : .yellow)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .padding(.bottom)
//        .padding(.bottom, 40)
        .background(Color.secondarySystemBackground)
        .padding(.top)
        
    }
    
    /// The wall of contribution contains all people that
    /// substantially worked on this app and made it possible.
    @ViewBuilder
    internal func wallOfFame() -> some View {
        
        WallOfContribution()
        
    }
    
}

struct AboutView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            AboutScreen(onOpenReview: {}, onOpenDeveloperLink: { _ in })
        }
        NavigationView {
            AboutScreen(onOpenReview: {}, onOpenDeveloperLink: { _ in })
        }.preferredColorScheme(.dark)
    }
    
}
