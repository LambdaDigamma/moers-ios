import SwiftUI

public struct AppUpdateBannerView: View {
    private let presentation: AppUpdatePresentation
    private let copy: AppUpdateCopy
    private let onUpdate: (URL) -> Void
    private let onClose: () -> Void

    public init(
        presentation: AppUpdatePresentation,
        copy: AppUpdateCopy = AppUpdateCopy(),
        onUpdate: @escaping (URL) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.presentation = presentation
        self.copy = copy
        self.onUpdate = onUpdate
        self.onClose = onClose
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.app.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(copy.bannerTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(copy.bannerMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                onUpdate(presentation.storeURL)
            } label: {
                Text(copy.updateButtonTitle)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.accentColor))
            }
            .buttonStyle(.plain)

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(copy.closeButtonTitle))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.06))
    }
}
