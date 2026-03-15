//
//  AboutView.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import SwiftUI

public enum DeveloperLinkType {
    case website
    case twitter
    case instagram
}

public struct About: View {
    
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    Image("Icon")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 150)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
                        .padding(.top)
                    
                    VStack(spacing: 4) {
                        
                        Text("moers festival")
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
                    .padding(.bottom, 80)
                
            }
            
        }
        .navigationTitle(Text("Über"))
        .navigationBarTitleDisplayMode(.large)
        
    }
    
    // MARK: - Social Link Button (Liquid Glass)
    
    @ViewBuilder
    private func socialLink(text: String, image: Image, action: @escaping () -> Void) -> some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                VStack(spacing: 6) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text(text)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.glass) // Liquid Glass button
            .tint(.white)
            .foregroundStyle(.white)
//            .tint(colorScheme == .light ? .blue : .white)
            .frame(maxWidth: .infinity)
            
        } else {
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
    }
    
    // MARK: - Text
    
    @ViewBuilder
    private func text() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Diese App wird seit 2018 von Lennart Fischer entwickelt und gepflegt. Anfangs noch reines Volunteer-Projekt, ist sie nun zu einem essentiellen Bestandteil des Festivals geworden. Falls Du Ideen für neue Funktionen hast, dann schreib mir gerne ein Feedback. Außerdem freue ich mich über eine (gute) Bewertung im App Store.")
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal)
        
    }
    
    // MARK: - Actions (Liquid Glass primary button)
    
    @ViewBuilder
    private func actions() -> some View {
        
        VStack {
            
            if #available(iOS 26.0, *) {
                
                Button(action: onOpenReview) {
                    
                    Label("Rate the App", systemImage: "star.fill")
                        .fontWeight(.semibold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .tint(.accentColor)
                .accessibilityIdentifier("About.rateButton")
                
            } else {
                Button("App bewerten", action: onOpenReview)
                    .buttonStyle(ProminentButtonStyle())
                    .accessibility(identifier: "About.rateButton")
            }
            
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    // MARK: - Developer Card (Liquid Glass container)
    
    @ViewBuilder
    private func developer() -> some View {
        
        let baseContent = VStack(spacing: 20) {
            
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

            baseContent
                .background(Color.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .padding(.horizontal)
                .padding(.top)
        
    }
    
}

// MARK: - Preview

struct About_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            About(onOpenReview: {}, onOpenDeveloperLink: { _ in })
        }
        NavigationView {
            About(onOpenReview: {}, onOpenDeveloperLink: { _ in })
        }.preferredColorScheme(.dark)
    }
    
}
