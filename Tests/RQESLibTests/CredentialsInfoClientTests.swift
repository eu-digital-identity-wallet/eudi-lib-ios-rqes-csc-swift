/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import XCTest
@testable import RQESLib

class CredentialsInfoClientTests: XCTestCase {
    var mockSession: MockHTTPClient!
    var client: CredentialsInfoClient!

    override func setUp() {
        super.setUp()
        mockSession = MockHTTPClient()
        client = CredentialsInfoClient(httpClient: mockSession)
    }

    override func tearDown() {
        client = nil
        mockSession = nil
        super.tearDown()
    }

    func testMakeRequestSuccessfulResponseParsing() async throws {
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsInfoRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        mockSession.setMockResponse(for: url, data: responseData, statusCode: 200)

        let result = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        switch result {
        case .success(let response):
            XCTAssertEqual(response.description, "This is a credential for tests")
            XCTAssertEqual(response.signatureQualifier?.rawValue, "eu_eidas_qes")
            XCTAssertEqual(response.multisign, 1)
            XCTAssertEqual(response.lang, "en-US")

            XCTAssertNotNil(response.cert, "Certificate info should be present")
            XCTAssertEqual(response.cert?.serialNumber, "184966370757515800362535864175063713398032096472")
            XCTAssertEqual(response.cert?.status, "valid")
            XCTAssertEqual(response.cert?.validFrom, "20250321220513Z")
            XCTAssertEqual(response.cert?.validTo, "20270321220512Z")
            XCTAssertEqual(response.cert?.subjectDN, "C=FC, GIVENNAME=FirstName, SURNAME=TesterUser, CN=FirstName TesterUser")
            XCTAssertEqual(response.cert?.issuerDN, "C=UT, O=EUDI Wallet Reference Implementation, CN=PID Issuer CA - UT 01")
            XCTAssertEqual(response.cert?.certificates?.count, 2)

            XCTAssertEqual(response.key.status, "enabled")
            XCTAssertEqual(response.key.curve, "1.2.840.10045.3.1.7")
            XCTAssertEqual(response.key.len, 256)
            XCTAssertEqual(response.key.algo.count, 2)
            XCTAssertEqual(response.key.algo, ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"])
        case .failure(let error):
            XCTFail("Expected successful parsing, but got error: \(error)")
        }
    }

    func testMakeRequestHttpErrorsReturnCorrectClientErrors() async throws {
        let testCases: [(statusCode: Int, message: String)] = [
            (400, "Bad Request"),
            (401, "Unauthorized"),
            (404, "Credential not found"),
            (500, "Internal Server Error")
        ]
        
        for testCase in testCases {
            let request = TestConstants.standardCredentialsInfoRequest
            let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
            mockSession.setMockResponse(for: url, data: testCase.message.data(using: .utf8)!, statusCode: testCase.statusCode)

            let result = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

            switch result {
            case .success:
                XCTFail("Expected failure for HTTP \(testCase.statusCode), but got success")
            case .failure(let error):
                if case .clientError(let message, let statusCode) = error {
                    XCTAssertEqual(statusCode, testCase.statusCode, "Status code should match")
                    XCTAssertEqual(message, testCase.message, "Error message should match")
                } else {
                    XCTFail("Expected ClientError.clientError for HTTP \(testCase.statusCode), but got \(error)")
                }
            }
        }
    }

    func testMakeRequestInvalidJsonReturnsClientError() async throws {
        let request = TestConstants.standardCredentialsInfoRequest
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        mockSession.setMockResponse(for: url, data: "invalid json data".data(using: .utf8)!, statusCode: 200)

        let result = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        switch result {
        case .success:
            XCTFail("Expected failure due to invalid JSON, but got success")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 200)
                XCTAssertEqual(message, "invalid json data")
            } else {
                XCTFail("Expected ClientError.clientError for invalid JSON, but got \(error)")
            }
        }
    }

    func testMakeRequestNetworkErrorPropagatesToCaller() async {
        let request = TestConstants.standardCredentialsInfoRequest
        let networkError = URLError(.notConnectedToInternet)
        mockSession.setMockError(networkError)

        do {
            _ = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
            XCTFail("Expected network error to be thrown")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet, "Should propagate specific network error")
        } catch {
            XCTFail("Expected URLError, but got \(type(of: error)): \(error)")
        }
    }

    func testMakeRequestInvalidUrlThrowsError() async {
        let request = TestConstants.standardCredentialsInfoRequest

        do {
            _ = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: "not-a-valid-url")
            XCTFail("Expected URL construction error to be thrown")
        } catch {
            XCTAssertTrue(true, "URL construction error thrown as expected")
        }
    }

    func testMakeRequestConstructsCorrectHttpRequest() async throws {
        let capturingMock = CapturingMockHTTPClient()
        let clientWithCapturing = CredentialsInfoClient(httpClient: capturingMock)
        
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsInfoRequest
        let accessToken = "test-access-token-123"
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        capturingMock.setMockResponse(for: url, data: responseData, statusCode: 200)

        _ = try await clientWithCapturing.makeRequest(for: request, accessToken: accessToken, rsspUrl: TestConstants.rsspUrl)

        XCTAssertNotNil(capturingMock.lastCapturedRequest, "Should capture the HTTP request")
        
        guard let capturedRequest = capturingMock.lastCapturedRequest else {
            XCTFail("No request was captured")
            return
        }

        XCTAssertTrue(capturedRequest.url?.absoluteString.contains("/credentials/info") == true, "Should call correct endpoint")
        XCTAssertEqual(capturedRequest.httpMethod, "POST", "Should use POST method")

        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer \(accessToken)")

        XCTAssertNotNil(capturedRequest.httpBody, "Should include request body")
        if let bodyData = capturedRequest.httpBody {
            let decodedRequest = try JSONDecoder().decode(CredentialsInfoRequest.self, from: bodyData)
            XCTAssertEqual(decodedRequest.credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
            XCTAssertEqual(decodedRequest.certInfo, true)
            XCTAssertEqual(decodedRequest.authInfo, true)
            XCTAssertEqual(decodedRequest.certificates, "chain")
        }
    }

    func testMakeRequestWithMinimalRequestParameters() async throws {
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let minimalRequest = CredentialsInfoRequest(
            credentialID: "test-credential-id",
            certificates: nil,
            certInfo: nil,
            authInfo: nil,
            lang: nil,
            clientData: nil
        )
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        mockSession.setMockResponse(for: url, data: responseData, statusCode: 200)

        let result = try await client.makeRequest(for: minimalRequest, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        switch result {
        case .success(let response):
            XCTAssertEqual(response.description, "This is a credential for tests")
        case .failure(let error):
            XCTFail("Should handle minimal request parameters, but got error: \(error)")
        }
    }
} 
