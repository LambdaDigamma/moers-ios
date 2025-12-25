import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EventServiceTests.allTests),
        testCase(EventViewModelTests.allTests),
        testCase(PackageConfigurationTest.allTests),
    ]
}
#endif
