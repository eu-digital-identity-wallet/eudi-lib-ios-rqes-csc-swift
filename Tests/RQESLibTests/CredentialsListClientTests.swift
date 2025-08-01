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

class CredentialsListClientTests: XCTestCase {
    var mockSession: MockHTTPClient!
    var client: CredentialsListClient!

    override func setUp() {
        super.setUp()
        mockSession = MockHTTPClient()
        client = CredentialsListClient(httpClient: mockSession)
    }

    override func tearDown() {
        client = nil
        mockSession = nil
        super.tearDown()
    }

    func testMakeRequestSuccessfulResponseParsing() async throws {
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsListRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockSession.setMockResponse(for: url, data: responseData, statusCode: 200)

        let result = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        switch result {
        case .success(let response):
            XCTAssertEqual(response.credentialIDs, ["662e92ed-cbeb-4d4f-9a46-8fc4df3cea85"], "Should parse credential IDs correctly")
            XCTAssertEqual(response.onlyValid, false, "Should parse onlyValid flag correctly")

            XCTAssertNotNil(response.credentialInfos, "Should contain credential info array")
            XCTAssertEqual(response.credentialInfos?.count, 1, "Should contain one credential")
            
            guard let firstCredential = response.credentialInfos?.first else {
                XCTFail("First credential should be present")
                return
            }

            XCTAssertEqual(firstCredential.credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
            XCTAssertEqual(firstCredential.description, "This is a credential for tests")
            XCTAssertEqual(firstCredential.signatureQualifier?.rawValue, "eu_eidas_qes")
            XCTAssertEqual(firstCredential.multisign, 1)
            XCTAssertEqual(firstCredential.lang, "en-US")

            XCTAssertEqual(firstCredential.cert.certificates.count, 2, "Should contain certificate chain")
            XCTAssertEqual(firstCredential.cert.serialNumber, "184966370757515800362535864175063713398032096472")
            XCTAssertEqual(firstCredential.cert.status, "valid")

            XCTAssertEqual(firstCredential.key.status, "enabled")
            XCTAssertEqual(firstCredential.key.len, 256)
            XCTAssertEqual(firstCredential.key.algo.count, 2, "Should contain multiple algorithms")
            
        case .failure(let error):
            XCTFail("Expected successful parsing, but got error: \(error)")
        }
    }

    func testMakeRequestHttpErrorsReturnCorrectClientErrors() async throws {
        let testCases: [(statusCode: Int, message: String)] = [
            (400, "Bad Request"),
            (401, "Unauthorized"),
            (404, "Credentials not found"),
            (500, "Internal Server Error")
        ]
        
        for testCase in testCases {
            let request = TestConstants.standardCredentialsListRequest
            let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
            mockSession.setMockResponse(for: url, data: testCase.message.data(using: .utf8)!, statusCode: testCase.statusCode)

            let result = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

            switch result {
            case .success:
                XCTFail("Expected failure for HTTP \(testCase.statusCode), but got success")
            case .failure(let error):
                if case .clientError(let message, let statusCode) = error {
                    XCTAssertEqual(statusCode, testCase.statusCode, "Status code should match for HTTP \(testCase.statusCode)")
                    XCTAssertEqual(message, testCase.message, "Error message should match for HTTP \(testCase.statusCode)")
                } else {
                    XCTFail("Expected ClientError.clientError for HTTP \(testCase.statusCode), but got \(error)")
                }
            }
        }
    }

    func testMakeRequestInvalidJsonReturnsClientError() async throws {
        let request = TestConstants.standardCredentialsListRequest
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
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
        let request = TestConstants.standardCredentialsListRequest
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
        let request = TestConstants.standardCredentialsListRequest

        do {
            _ = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: "not-a-valid-url")
            XCTFail("Expected URL construction error to be thrown")
        } catch {
            XCTAssertTrue(true, "URL construction error thrown as expected")
        }
    }

    func testMakeRequestConstructsCorrectHttpRequest() async throws {
        let capturingMock = CapturingMockHTTPClient()
        let clientWithCapturing = CredentialsListClient(httpClient: capturingMock)
        
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsListRequest
        let accessToken = "test-access-token-123"
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        capturingMock.setMockResponse(for: url, data: responseData, statusCode: 200)

        _ = try await clientWithCapturing.makeRequest(for: request, accessToken: accessToken, rsspUrl: TestConstants.rsspUrl)

        XCTAssertNotNil(capturingMock.lastCapturedRequest, "Should capture the HTTP request")
        
        guard let capturedRequest = capturingMock.lastCapturedRequest else {
            XCTFail("No request was captured")
            return
        }

        XCTAssertTrue(capturedRequest.url?.absoluteString.contains("/credentials/list") == true, "Should call correct endpoint")
        XCTAssertEqual(capturedRequest.httpMethod, "POST", "Should use POST method")

        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer \(accessToken)")

        XCTAssertNotNil(capturedRequest.httpBody, "Should include request body")
        if let bodyData = capturedRequest.httpBody {
            let decodedRequest = try JSONDecoder().decode(CredentialsListRequest.self, from: bodyData)
            XCTAssertEqual(decodedRequest.certInfo, true)
            XCTAssertEqual(decodedRequest.credentialInfo, true)
            XCTAssertEqual(decodedRequest.certificates, "chain")
        }
    }

    func testMakeRequestWithMinimalRequestParameters() async throws {
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!
        let minimalRequest = CredentialsListRequest(
            userID: nil,
            credentialInfo: false,
            certificates: nil,
            certInfo: false,
            authInfo: nil,
            onlyValid: nil,
            lang: nil,
            clientData: nil
        )
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockSession.setMockResponse(for: url, data: responseData, statusCode: 200)

        let result = try await client.makeRequest(for: minimalRequest, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        switch result {
        case .success(let response):
            XCTAssertEqual(response.credentialIDs.count, 1, "Should handle minimal request parameters")
            XCTAssertNotNil(response.credentialInfos, "Should parse response even with minimal request")
        case .failure(let error):
            XCTFail("Should handle minimal request parameters, but got error: \(error)")
        }
    }

    func testMakeRequestWithEmptyCredentialsListResponse() async throws {
        let emptyListResponse = """
        {
          "credentialInfos": [],
          "onlyValid": true,
          "credentialIDs": []
        }
        """.data(using: .utf8)!
        
        let request = TestConstants.standardCredentialsListRequest
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockSession.setMockResponse(for: url, data: emptyListResponse, statusCode: 200)

        let result = try await client.makeRequest(for: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        switch result {
        case .success(let response):
            XCTAssertEqual(response.credentialIDs.count, 0, "Should handle empty credentials list")
            XCTAssertEqual(response.credentialInfos?.count, 0, "Should handle empty credential infos")
            XCTAssertEqual(response.onlyValid, true, "Should parse onlyValid flag correctly")
        case .failure(let error):
            XCTFail("Should handle empty credentials list response, but got error: \(error)")
        }
    }
} 
