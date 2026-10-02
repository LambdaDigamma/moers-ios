import AVFoundation
import OSLog

/// Loads language options once per item and rejects canceled or replaced-item results.
@MainActor
final class MediaSelectionLoader {
    typealias Loading = @MainActor (AVAsset) async throws -> [AVMediaSelectionGroup]

    private let loadGroups: Loading
    private let logger = Logger(.default)
    private var item: AVPlayerItem?
    private var task: Task<Void, Never>?
    private(set) var groups: [AVMediaSelectionGroup] = []

    init(loadGroups: @escaping Loading = MediaSelectionLoader.loadGroups) {
        self.loadGroups = loadGroups
    }

    func load(for item: AVPlayerItem, onLoad: @escaping () -> Void) {
        guard self.item !== item else { return }

        cancel()
        self.item = item
        let loadGroups = self.loadGroups
        let asset = item.asset

        task = Task { [weak self] in
            do {
                let groups = try await loadGroups(asset)
                guard !Task.isCancelled, let self, self.item === item else { return }
                self.groups = groups
                self.task = nil
                onLoad()
            } catch {
                guard !Task.isCancelled, let self, self.item === item else { return }
                self.task = nil
                self.logger.error("Failed to load media selection groups: \(error.localizedDescription)")
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        item = nil
        groups = []
    }

    private static func loadGroups(from asset: AVAsset) async throws -> [AVMediaSelectionGroup] {
        let characteristics = try await asset.load(.availableMediaCharacteristicsWithMediaSelectionOptions)
        var groups: [AVMediaSelectionGroup] = []
        for characteristic in characteristics where characteristic == .audible || characteristic == .legible {
            try Task.checkCancellation()
            if let group = try await asset.loadMediaSelectionGroup(for: characteristic) {
                groups.append(group)
            }
        }
        return groups
    }

    nonisolated deinit {
        task?.cancel()
    }
}
