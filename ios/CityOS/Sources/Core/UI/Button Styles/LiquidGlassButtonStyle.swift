//
//  LiquidGlassButtonStyle.swift
//  
//
//  Created by GitHub Copilot on 27.12.24.
//

import SwiftUI

/// A modern button style that provides the Liquid Glass design pattern
/// with enhanced appearance on iOS 18+ and fallback support for iOS 16-17.
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
            // iOS 18+ with enhanced contrast for better accessibility
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
                makePrimaryButton(configuration: configuration, background: Color.yellow)
            case .secondary:
                makeSecondaryButton(configuration: configuration, includeOverlay: true)
            }
        }
    }
    
    // MARK: - iOS 16-17 Fallback
    
    @ViewBuilder
    private func makeLegacyButton(configuration: Configuration) -> some View {
        switch prominence {
        case .primary:
            makePrimaryButton(configuration: configuration, background: Color.yellow)
        case .secondary:
            makeSecondaryButton(configuration: configuration, includeOverlay: false)
        }
    }
    
    // MARK: - Helper Methods
    
    private func makePrimaryButton(configuration: Configuration, background: Color) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(background)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
    
    @ViewBuilder
    private func makeSecondaryButton(configuration: Configuration, includeOverlay: Bool) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding()
            .foregroundColor(.yellow)
            .frame(maxWidth: .infinity, alignment: .center)
            .background {
                if includeOverlay {
                    ZStack {
                        Color(UIColor.secondarySystemBackground)
                        Color.black.opacity(0.1)
                    }
                } else {
                    Color(UIColor.secondarySystemBackground)
                }
            }
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
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
