import XCTest
@testable import RQESLib

final class OcspClientTests: XCTestCase {

    var mockHttpClient: MockHTTPClient!
    var ocspClient: OcspClient!

    override func setUp() {
        super.setUp()
        mockHttpClient = MockHTTPClient()
        ocspClient = OcspClient(httpClient: mockHttpClient)
    }

    override func tearDown() {
        mockHttpClient = nil
        ocspClient = nil
        super.tearDown()
    }

    func testMakeRequestSuccess() async {
        let request = OcspRequest(ocspUrl: OcspTestConstants.URLs.ocspUrl, ocspRequest: OcspTestConstants.MockData.request)
        mockHttpClient.setMockResponse(for: OcspTestConstants.URLs.ocspUrl, data: OcspTestConstants.MockData.successResponse)
        
        let result = await ocspClient.makeRequest(for: request)

        switch result {
        case .success(let data):
            XCTAssertEqual(data, OcspTestConstants.MockData.successResponse)
        case .failure(let error):
            XCTFail("Request should not have failed: \(error)")
        }
    }

    func testMakeRequestClientError() async {
        let request = OcspRequest(ocspUrl: OcspTestConstants.URLs.ocspUrl, ocspRequest: OcspTestConstants.MockData.request)
        mockHttpClient.setMockResponse(for: OcspTestConstants.URLs.ocspUrl, data: OcspTestConstants.MockData.errorResponse, statusCode: 400)

        let result = await ocspClient.makeRequest(for: request)

        switch result {
        case .success:
            XCTFail("Request should have failed.")
        case .failure(let error as ClientError):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(message, String(data: OcspTestConstants.MockData.errorResponse, encoding: .utf8))
                XCTAssertEqual(statusCode, 400)
            } else {
                XCTFail("Incorrect error type returned")
            }
        default:
            XCTFail("Incorrect error type returned")
        }
    }

    func testMakeRequestBadUrl() async {
        let request = OcspRequest(ocspUrl: OcspTestConstants.URLs.badUrl, ocspRequest: OcspTestConstants.MockData.request)
        
        let result = await ocspClient.makeRequest(for: request)
        
        switch result {
        case .success:
            XCTFail("Request should have failed.")
        case .failure(let error):
            XCTAssertTrue(error is URLError)
        }
    }
}
