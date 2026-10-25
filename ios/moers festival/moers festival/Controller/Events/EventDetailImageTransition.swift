import SwiftUI

struct EventDetailImageTransition: ViewModifier {
    let height: CGFloat
    var isBlurEnabled = true

    private let radius: CGFloat = 12

    private var transitionHeight: CGFloat {
        min(height * 0.45, 180)
    }

    func body(content: Content) -> some View {
        content
            .layerEffect(
                ShaderLibrary.eventDetailProgressiveBlur(
                    .boundingRect, .float2(1, 0), .float(transitionHeight), .float(radius)
                ),
                maxSampleOffset: CGSize(width: radius, height: 0),
                isEnabled: isBlurEnabled
            )
            .layerEffect(
                ShaderLibrary.eventDetailProgressiveBlur(
                    .boundingRect, .float2(0, 1), .float(transitionHeight), .float(radius)
                ),
                maxSampleOffset: CGSize(width: 0, height: radius),
                isEnabled: isBlurEnabled
            )
            .overlay(alignment: .bottom) {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: Color(uiColor: .systemBackground).opacity(0.04), location: 0.2),
                        .init(color: Color(uiColor: .systemBackground).opacity(0.16), location: 0.4),
                        .init(color: Color(uiColor: .systemBackground).opacity(0.42), location: 0.6),
                        .init(color: Color(uiColor: .systemBackground).opacity(0.78), location: 0.8),
                        .init(color: Color(uiColor: .systemBackground), location: 0.96),
                        .init(color: Color(uiColor: .systemBackground), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: transitionHeight)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
    }
}

#Preview("Image transition") {
    VStack(spacing: 0) {
        LinearGradient(colors: [.orange, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: "waveform")
                    .font(.system(size: 180))
                    .foregroundStyle(.white)
            }
            .frame(height: 360)
            .modifier(EventDetailImageTransition(height: 360))
        Color(uiColor: .systemBackground).frame(height: 100)
    }
    .frame(width: 380)
}
