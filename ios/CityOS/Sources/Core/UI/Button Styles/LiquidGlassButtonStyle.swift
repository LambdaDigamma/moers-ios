//
//  LiquidGlassButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 27.12.24.
//

import SwiftUI

/// A modern button style that provides the Liquid Glass design pattern
/// with native Liquid Glass on iOS 26+ and graceful fallbacks for earlier versions.
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
        Group {
            if #available(iOS 26.0, *) {
                liquidGlass(configuration)
            } else if #available(iOS 18.0, *) {
                modernFallback(configuration, enhancedContrast: true)
            } else {
                modernFallback(configuration, enhancedContrast: false)
            }
        }
        .scaleEffect(configuration.isPressed ? 0.97 : 1)
        .opacity(configuration.isPressed ? 0.85 : 1)
        .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - iOS 26+ Liquid Glass

@available(iOS 26.0, *)
private extension LiquidGlassButtonStyle {
    
    func liquidGlass(_ configuration: Configuration) -> some View {
        baseLabel(configuration)
            .foregroundStyle(foregroundStyle)
            .glassEffect(glassEffect)
    }
    
    var glassEffect: Glass {
        switch prominence {
            case .primary:
                return .regular
                    .tint(.yellow.opacity(0.8))
                    .interactive()
            case .secondary:
                return .regular
                    .interactive()
        }
    }
}

// MARK: - iOS 16–25 Fallbacks

private extension LiquidGlassButtonStyle {
    
    func modernFallback(
        _ configuration: Configuration,
        enhancedContrast: Bool
    ) -> some View {
        baseLabel(configuration)
            .foregroundStyle(foregroundStyle)
            .background(background(enhancedContrast: enhancedContrast))
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
    }
    
    @ViewBuilder
    func background(enhancedContrast: Bool) -> some View {
        switch prominence {
            case .primary:
                Color.yellow
            case .secondary:
                ZStack {
                    Color(UIColor.secondarySystemBackground)
                    if enhancedContrast {
                        Color.black.opacity(0.08)
                    }
                }
        }
    }
}

// MARK: - Shared Styling

private extension LiquidGlassButtonStyle {
    
    func baseLabel(_ configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding(.horizontal, Metrics.horizontalPadding)
            .padding(.vertical, Metrics.verticalPadding)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }
    
    var foregroundStyle: some ShapeStyle {
        switch prominence {
            case .primary:
                return AnyShapeStyle(Color.black)
            case .secondary:
                return AnyShapeStyle(Color.yellow)
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 14
    static let cornerRadius: CGFloat = 12
}

// MARK: - Convenience Extensions

public extension Button {
    
    func liquidGlassPrimary() -> some View {
        buttonStyle(LiquidGlassButtonStyle(prominence: .primary))
    }
    
    func liquidGlassSecondary() -> some View {
        buttonStyle(LiquidGlassButtonStyle(prominence: .secondary))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            Text("Liquid Glass Buttons")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Button("Primary Button") {}
                .liquidGlassPrimary()
            
            Button("Secondary Button") {}
                .liquidGlassSecondary()
            
            Button {
            } label: {
                Label("Button with Icon", systemImage: "bell.circle.fill")
            }
            .liquidGlassSecondary()
            
            Button("Disabled Button") {}
                .liquidGlassPrimary()
                .disabled(true)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
