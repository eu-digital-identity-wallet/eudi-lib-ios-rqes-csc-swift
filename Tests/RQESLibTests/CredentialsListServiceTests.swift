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

class CredentialsListServiceTests: XCTestCase {
    var mockHTTPClient: MockHTTPClient!
    var credentialsListClient: CredentialsListClient!
    var service: CredentialsListService!

    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        credentialsListClient = CredentialsListClient(httpClient: mockHTTPClient)
        service = CredentialsListService(credentialsListClient: credentialsListClient)
    }

    override func tearDown() {
        service = nil
        credentialsListClient = nil
        mockHTTPClient = nil
        super.tearDown()
    }

    func testGetCredentialsListSuccessfulIntegration() async throws {
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsListRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await service.getCredentialsList(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.credentialIDs, ["662e92ed-cbeb-4d4f-9a46-8fc4df3cea85"], "Should return correct credential IDs")
        XCTAssertEqual(response.onlyValid, false, "Should preserve onlyValid flag")

        XCTAssertNotNil(response.credentialInfos, "Should contain credential infos")
        XCTAssertEqual(response.credentialInfos?.count, 1, "Should contain one credential")
        
        guard let firstCredential = response.credentialInfos?.first else {
            XCTFail("First credential should be present")
            return
        }
        
        XCTAssertEqual(firstCredential.credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
        XCTAssertEqual(firstCredential.description, "This is a credential for tests")
        XCTAssertEqual(firstCredential.signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(firstCredential.multisign, 1)

        XCTAssertEqual(firstCredential.cert.certificates.count, 2, "Should have certificate chain")
        XCTAssertEqual(firstCredential.key.status, "enabled")
        XCTAssertEqual(firstCredential.key.algo.count, 2, "Should have multiple algorithms")
    }

    func testGetCredentialsListHandlesEmptyCredentialsList() async throws {
        let emptyResponseData = TestConstants.emptyCredentialsListResponseForService.data(using: .utf8)!
        
        let request = TestConstants.standardCredentialsListRequest
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: emptyResponseData, statusCode: 200)
        
        let response = try await service.getCredentialsList(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
        
        XCTAssertEqual(response.credentialIDs.count, 0, "Should handle empty credentials list")
        XCTAssertEqual(response.credentialInfos?.count, 0, "Should handle empty credential infos")
        XCTAssertEqual(response.onlyValid, true, "Should correctly parse onlyValid flag")
    }

    func testGetCredentialsListPropagatesClientErrors() async {
        let request = TestConstants.standardCredentialsListRequest
        let url = try! TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        
        let testCases: [(statusCode: Int, message: String)] = [
            (400, "Bad Request"),
            (401, "Unauthorized"),
            (404, "Credentials not found"),
            (500, "Internal Server Error")
        ]
        
        for testCase in testCases {
            mockHTTPClient.setMockResponse(for: url, data: testCase.message.data(using: .utf8)!, statusCode: testCase.statusCode)
            
            do {
                _ = try await service.getCredentialsList(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
                XCTFail("Expected error for HTTP \(testCase.statusCode)")
            } catch ClientError.clientError(let message, let statusCode) {
                XCTAssertEqual(statusCode, testCase.statusCode, "Should propagate correct status code")
                XCTAssertEqual(message, testCase.message, "Should propagate correct error message")
            } catch {
                XCTFail("Expected ClientError.clientError for HTTP \(testCase.statusCode), but got \(type(of: error)): \(error)")
            }
        }
    }

    func testGetCredentialsListPropagatesNetworkErrors() async {
        let request = TestConstants.standardCredentialsListRequest
        let networkError = URLError(.notConnectedToInternet)
        mockHTTPClient.setMockError(networkError)
        
        do {
            _ = try await service.getCredentialsList(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
            XCTFail("Expected network error to be propagated")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet, "Should propagate specific network error")
        } catch {
            XCTFail("Expected URLError, but got \(type(of: error)): \(error)")
        }
    }

    func testServiceUsesDependencyInjectedClient() async throws {
        let capturingMock = CapturingMockHTTPClient()
        let customClient = CredentialsListClient(httpClient: capturingMock)
        let customService = CredentialsListService(credentialsListClient: customClient)
        
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsListRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        capturingMock.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await customService.getCredentialsList(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.credentialIDs.count, 1, "Should return correct response through injected client")

        XCTAssertNotNil(capturingMock.lastCapturedRequest, "Should use injected client")
        XCTAssertTrue(capturingMock.lastCapturedRequest?.url?.absoluteString.contains("/credentials/list") == true, "Should call correct endpoint through injected client")
    }

    func testGetCredentialsListWithMultipleCredentials() async throws {
        let multipleCredentialsResponse = TestConstants.multipleCredentialsResponseForService.data(using: .utf8)!
        
        let request = TestConstants.standardCredentialsListRequest
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: multipleCredentialsResponse, statusCode: 200)
        
        let response = try await service.getCredentialsList(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.credentialIDs.count, 2, "Should handle multiple credentials")
        XCTAssertEqual(response.credentialInfos?.count, 2, "Should contain multiple credential infos")
        XCTAssertEqual(response.credentialIDs, ["662e92ed-cbeb-4d4f-9a46-8fc4df3cea85", "another-credential-id"])
        
        guard let credentials = response.credentialInfos, credentials.count >= 2 else {
            XCTFail("Should have at least 2 credentials")
            return
        }

        XCTAssertEqual(credentials[0].credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
        XCTAssertEqual(credentials[0].signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(credentials[0].multisign, 1)

        XCTAssertEqual(credentials[1].credentialID, "another-credential-id")
        XCTAssertEqual(credentials[1].signatureQualifier?.rawValue, "eu_eidas_ades")
        XCTAssertEqual(credentials[1].multisign, 5)
        XCTAssertEqual(credentials[1].lang, "es-ES")
    }

    func testGetCredentialsListWithOptionalParameters() async throws {
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!

        let requestWithOptionals = CredentialsListRequest(
            userID: "test-user-id",
            credentialInfo: true,
            certificates: "single",
            certInfo: false,
            authInfo: true,
            onlyValid: true,
            lang: "de-DE",
            clientData: "custom-client-data"
        )
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await service.getCredentialsList(request: requestWithOptionals, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.credentialIDs.count, 1, "Should handle request with optional parameters")
        XCTAssertNotNil(response.credentialInfos, "Should return credential infos")
    }

    func testGetCredentialsListHandlesMinimalRequest() async throws {
        let responseData = TestConstants.credentialsListResponse.data(using: .utf8)!
        let minimalRequest = TestConstants.minimalCredentialsListRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/list").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await service.getCredentialsList(request: minimalRequest, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.credentialIDs.count, 1, "Should handle minimal request")
        XCTAssertNotNil(response.credentialInfos, "Should return credential infos even with minimal request")
    }
} 
