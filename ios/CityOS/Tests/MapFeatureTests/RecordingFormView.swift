@testable import MapFeature

@MainActor
final class RecordingFormView: FormView {
    private let value: String

    init(value: String) { self.value = value }
    func currentData() -> any Codable { value }
    func displayErrors(_ errors: [String]) {}
}
