import MediaLibraryKit
import SwiftUI
import UIKit

/// Extends only the artwork. Credits, text, and controls stay in the safe area.
struct EventDetailHeroView: View {
    let media: Media
    let viewportSize: CGSize

    private var height: CGFloat {
        let width = CGFloat(max(media.responsiveWidth ?? 16, 1))
        let height = CGFloat(max(media.responsiveHeight ?? 9, 1))
        return min(viewportSize.width * height / width, viewportSize.height * 0.65, 520)
    }

    var body: some View {
        extendedArtwork
            .visualEffect { content, geometry in
                let pull = max(geometry.frame(in: .named("EventDetail.Scroll")).minY, 0)
                let scale = 1 + pull / max(geometry.size.height, 1)
                return content.scaleEffect(scale, anchor: .bottom)
            }
    }

    @ViewBuilder private var extendedArtwork: some View {
        if #available(iOS 26, tvOS 26, *) {
            artwork.backgroundExtensionEffect()
        } else {
            artwork
        }
    }

    private var artwork: some View {
        GenericMediaView(media: media, resizingMode: .aspectFill)
            .frame(width: viewportSize.width, height: height, alignment: .top)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, Color(uiColor: .systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: min(height * 0.3, 100))
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .accessibilityIdentifier("EventDetail.HeaderImage")
    }
}

#Preview {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("festival-header-preview.png")
    let image = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 180)).image { context in
        UIColor.systemIndigo.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 320, height: 180))
        UIColor.systemPink.setFill()
        context.fill(CGRect(x: 160, y: 0, width: 160, height: 180))
    }
    let savedImage = try? image.pngData()?.write(to: url)
    GeometryReader { geometry in
        ScrollView {
            EventDetailHeroView(
                media: Media(
                    id: 1, modelType: "Event", modelID: 1, uuid: nil,
                    collectionName: "header", fullURL: savedImage != nil ? url.absoluteString : nil,
                    name: "Preview", fileName: "preview.png",
                    size: 0, alt: "Event artwork", caption: nil, credits: nil
                ),
                viewportSize: geometry.size
            )
        }
        .coordinateSpace(name: "EventDetail.Scroll")
        .scrollBounceBehavior(.always, axes: .vertical)
    }
}
