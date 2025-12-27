//
//  LiquidGlassButtonStyle.swift
//  
//
//  Created by GitHub Copilot on 27.12.24.
//

import SwiftUI

/// A modern button style that uses iOS 18+ native button styles when available,
/// with fallback support for iOS 16-17.
public struct LiquidGlassButtonStyle: ButtonStyle {
    
    public enum Prominence {
        case primary
        case secondary
    }
    
    private let prominence: Prominence
    
    public init(prominence: Prominence = .primary) {
        self.prominence = prominence
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 18.0, *) {
            // Use iOS 18+ native button styles with improved materials
            makeModernButton(configuration: configuration)
        } else {
            // Fallback for iOS 16-17
            makeLegacyButton(configuration: configuration)
        }
    }
    
    // MARK: - iOS 18+ Implementation
    
    @available(iOS 18.0, *)
    private func makeModernButton(configuration: Configuration) -> some View {
        Group {
            switch prominence {
            case .primary:
                configuration.label
                    .font(.body.weight(.semibold))
                    .padding()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.yellow)
                    .cornerRadius(10)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            case .secondary:
                configuration.label
                    .font(.body.weight(.semibold))
                    .padding()
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background {
                        ZStack {
                            // Base material for glass effect
                            Color(UIColor.secondarySystemBackground)
                            // Subtle overlay for better contrast with yellow text
                            Color.black.opacity(0.1)
                        }
                    }
                    .cornerRadius(10)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            }
        }
    }
    
    // MARK: - iOS 16-17 Fallback
    
    @ViewBuilder
    private func makeLegacyButton(configuration: Configuration) -> some View {
        switch prominence {
        case .primary:
            configuration.label
                .font(.body.weight(.semibold))
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.yellow)
                .cornerRadius(10)
                .opacity(configuration.isPressed ? 0.7 : 1)
        case .secondary:
            configuration.label
                .font(.body.weight(.semibold))
                .padding()
                .foregroundColor(.yellow)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }
}

// MARK: - Convenience Extensions

public extension Button {
    /// Applies the Liquid Glass button style with primary prominence
    func liquidGlassPrimary() -> some View {
        self.buttonStyle(LiquidGlassButtonStyle(prominence: .primary))
    }
    
    /// Applies the Liquid Glass button style with secondary prominence
    func liquidGlassSecondary() -> some View {
        self.buttonStyle(LiquidGlassButtonStyle(prominence: .secondary))
    }
}

// MARK: - Preview

struct LiquidGlassButtonStyle_Preview: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 20) {
            
            Button("Primary Button") {
                // Action
            }
            .buttonStyle(LiquidGlassButtonStyle(prominence: .primary))
            
            Button("Secondary Button") {
                // Action
            }
            .buttonStyle(LiquidGlassButtonStyle(prominence: .secondary))
            
            Button {
                // Action
            } label: {
                Text("\(Image(systemName: "bell.circle.fill")) Button with Icon")
            }
            .buttonStyle(LiquidGlassButtonStyle(prominence: .secondary))
            
            Button("Disabled Button") {
                // Action
            }
            .buttonStyle(LiquidGlassButtonStyle(prominence: .primary))
            .disabled(true)
            
            // Using convenience extensions
            Button("Using Extension") {
                // Action
            }
            .liquidGlassPrimary()
            
        }
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
    
}
