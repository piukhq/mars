import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JiraTicketUpdateTests.allTests),
    ]
}
#endif
