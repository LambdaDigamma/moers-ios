import MediaLibraryKit
import SwiftUI
import UIKit

/// Extends only the artwork. Credits, text, and controls stay in the safe area.
struct EventDetailHeroView: View {
    let media: Media
    let contentWidth: CGFloat
    let viewportHeight: CGFloat

    private var height: CGFloat {
        let width = CGFloat(max(media.responsiveWidth ?? 16, 1))
        let height = CGFloat(max(media.responsiveHeight ?? 9, 1))
        return min(contentWidth * height / width, viewportHeight * 0.65, 520)
    }

    var body: some View {
        GeometryReader { geometry in
            let pull = max(geometry.frame(in: .named("EventDetail.Scroll")).minY, 0)
            let artworkHeight = geometry.size.height + pull

            extendedArtwork(height: artworkHeight)
                .frame(height: artworkHeight)
                .offset(y: -pull)
        }
        .frame(height: height)
    }

    @ViewBuilder private func extendedArtwork(height: CGFloat) -> some View {
        if #available(iOS 26, tvOS 26, *) {
            artwork(height: height).backgroundExtensionEffect()
        } else {
            artwork(height: height)
        }
    }

    private func artwork(height: CGFloat) -> some View {
        EventDetailArtworkView(media: media, height: height)
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
                contentWidth: geometry.size.width,
                viewportHeight: geometry.size.height
            )
        }
        .coordinateSpace(name: "EventDetail.Scroll")
        .scrollBounceBehavior(.always, axes: .vertical)
    }
}
