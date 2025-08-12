import XCTest
@testable import RQESLib

final class CertificateClientTests: XCTestCase {

    var mockHttpClient: MockHTTPClient!
    var certificateClient: CertificateClient!

    override func setUp() {
        super.setUp()
        mockHttpClient = MockHTTPClient()
        certificateClient = CertificateClient(httpClient: mockHttpClient)
    }

    override func tearDown() {
        mockHttpClient = nil
        certificateClient = nil
        super.tearDown()
    }

    func testCertificateRequestInitialization() {
        let request = CertificateRequest(certificateUrl: OcspTestConstants.URLs.ocspUrl)
        XCTAssertEqual(request.certificateUrl, OcspTestConstants.URLs.ocspUrl)
    }

    func testCertificateResponseInitialization() {
        let response = CertificateResponse(certificateBase64: OcspTestConstants.MockData.successResponse.base64EncodedString())
        XCTAssertEqual(response.certificateBase64, OcspTestConstants.MockData.successResponse.base64EncodedString())
    }

    func testMakeRequestSuccess() async {
        let request = CertificateRequest(certificateUrl: OcspTestConstants.URLs.ocspUrl)
        mockHttpClient.setMockResponse(for: OcspTestConstants.URLs.ocspUrl, data: OcspTestConstants.MockData.successResponse)

        let result = await certificateClient.makeRequest(for: request)

        switch result {
        case .success(let data):
            XCTAssertEqual(data, OcspTestConstants.MockData.successResponse)
        case .failure(let error):
            XCTFail("Request should not have failed: \(error)")
        }
    }

    func testMakeRequestClientError() async {
        let request = CertificateRequest(certificateUrl: OcspTestConstants.URLs.ocspUrl)
        mockHttpClient.setMockResponse(for: OcspTestConstants.URLs.ocspUrl, data: OcspTestConstants.MockData.errorResponse, statusCode: 404)

        let result = await certificateClient.makeRequest(for: request)

        switch result {
        case .success:
            XCTFail("Request should have failed.")
        case .failure(let error as ClientError):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(message, String(data: OcspTestConstants.MockData.errorResponse, encoding: .utf8))
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Incorrect error type returned")
            }
        default:
            XCTFail("Incorrect error type returned")
        }
    }

    func testMakeRequestBadUrl() async {
        let request = CertificateRequest(certificateUrl: OcspTestConstants.URLs.badUrl)
        
        let result = await certificateClient.makeRequest(for: request)
        
        switch result {
        case .success:
            XCTFail("Request should have failed.")
        case .failure(let error):
            XCTAssertTrue(error is URLError)
        }
    }
}
