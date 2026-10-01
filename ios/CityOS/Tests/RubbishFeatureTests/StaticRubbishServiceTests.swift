import XCTest
@testable import RubbishFeature

@MainActor
final class StaticRubbishServiceTests: XCTestCase {
    
    func test_remindersEnabled() async {
        
        let service = StaticRubbishService()
        
        service.registerNotifications(at: 10, minute: 0)
        
        XCTAssertTrue(service.remindersEnabled)
        
        service.disableReminder()
        
        XCTAssertFalse(service.remindersEnabled)
        
    }
    
}
