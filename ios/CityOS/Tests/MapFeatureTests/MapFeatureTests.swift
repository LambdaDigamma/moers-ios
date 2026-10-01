import XCTest
@testable import MapFeature

@MainActor
final class MapFeatureTests: XCTestCase {
    func testFormReadsValuesFromRegisteredViews() async {
        let form = Form()
        let field = RecordingFormView(value: "Moers")
        form.registerView(for: "city", view: field)
        XCTAssertEqual(form.keyedValues()["city"] as? String, "Moers")
    }

    func testReplacingFormFieldUsesLatestValue() async {
        let form = Form()
        form.registerView(for: "city", view: RecordingFormView(value: "Moers"))
        form.registerView(for: "city", view: RecordingFormView(value: "Duisburg"))
        XCTAssertEqual(form.keyedValues().count, 1)
        XCTAssertEqual(form.keyedValues()["city"] as? String, "Duisburg")
    }
}
