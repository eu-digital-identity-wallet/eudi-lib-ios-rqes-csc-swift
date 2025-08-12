import XCTest
@testable import RQESLib

final class OcspModelTests: XCTestCase {

    func testOcspRequestInitialization() {
        let url = "https://example.com/ocsp"
        let requestData = "ocspRequestData"
        let ocspRequest = OcspRequest(ocspUrl: url, ocspRequest: requestData)

        XCTAssertEqual(ocspRequest.ocspUrl, url)
        XCTAssertEqual(ocspRequest.ocspRequest, requestData)
    }

    func testOcspResponseInitialization() {
        let responseData = "ocspResponseData"
        let ocspResponse = OcspResponse(ocspInfoBase64: responseData)

        XCTAssertEqual(ocspResponse.ocspInfoBase64, responseData)
    }
}
