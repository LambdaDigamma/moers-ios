import Observation

@Observable
final class VenueDetailLayoutState {
    var presentationContext: VenueDetailPresentationContext

    init(presentationContext: VenueDetailPresentationContext) {
        self.presentationContext = presentationContext
    }

    nonisolated deinit {}
}
