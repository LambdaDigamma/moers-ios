import SwiftUI

public struct AppUpdateSheetView: View {
    private let presentation: AppUpdatePresentation
    private let copy: AppUpdateCopy
    private let onUpdate: (URL) -> Void
    private let onClose: () -> Void

    @Environment(\.dismiss) private var dismiss

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
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Image(systemName: "arrow.down.app.fill")
                        .font(.system(size: 58, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 26)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(copy.sheetTitle)
                            .font(.title.weight(.semibold))
                            .foregroundColor(.primary)

                        Text(copy.sheetSubtitle)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(copy.sheetBody)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    if let version = presentation.version {
                        Text("Version \(version)")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.secondary.opacity(0.12)))
                    }

                    Button {
                        onUpdate(presentation.storeURL)
                    } label: {
                        Text(copy.updateButtonTitle)
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                    }
                    .buttonStyle(.plain)

                    if presentation.allowsDismissal == false {
                        Text(copy.sheetRequiredFooter)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(copy.closeButtonTitle) {
                        onClose()
                        dismiss()
                    }
                    .disabled(presentation.allowsDismissal == false)
                    .opacity(presentation.allowsDismissal ? 1 : 0)
                    .accessibilityHidden(presentation.allowsDismissal == false)
                }
            }
        }
    }
}
