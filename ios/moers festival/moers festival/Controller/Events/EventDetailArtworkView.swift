import MediaLibraryKit
import Nuke
import NukeUI
import SwiftUI

struct EventDetailArtworkView: View {
    let media: Media
    let height: CGFloat

    var body: some View {
        LazyImage(request: ImageRequest(stringLiteral: media.fullURL ?? "")) { state in
            Group {
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .accessibilityLabel(media.alt ?? "")
                        .accessibilityHidden(media.alt == nil)
                } else if let error = state.error {
                    Text((error as? ImagePipeline.Error)?.description ?? error.localizedDescription)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .frame(minWidth: 200)
                        .padding()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .clipped()
            .modifier(EventDetailImageTransition(height: height, isBlurEnabled: state.image != nil))
        }
        .pipeline(.shared)
    }
}
