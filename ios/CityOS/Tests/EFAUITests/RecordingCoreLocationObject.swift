import CoreLocation
@testable import Core

@MainActor
final class RecordingCoreLocationObject: CoreLocationObject {
    private(set) var startCount = 0
    private(set) var stopCount = 0

    override func beginUpdates(_ status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse { startCount += 1 }
    }

    override func endUpdates() { stopCount += 1 }
}
