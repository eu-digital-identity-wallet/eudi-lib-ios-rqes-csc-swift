import XCTest
@testable import RQESLib

final class OCSPErrorTests: XCTestCase {

    func testBothMethodsFailedErrorDescription() {
        let primaryError = "Primary error message"
        let fallbackError = "Fallback error message"
        let error = OCSPError.bothMethodsFailed(primaryError: primaryError, fallbackError: fallbackError)

        let expectedDescription = "Both primary and fallback OCSP methods failed. Primary: \(primaryError). Fallback: \(fallbackError)."
        XCTAssertEqual(error.errorDescription, expectedDescription, "The error description should match the expected format.")
    }
}
