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

final class SignHashClientTests: XCTestCase {
    
    var signHashClient: SignHashClient!
    var mockHTTPClient: MockHTTPClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        signHashClient = SignHashClient(httpClient: mockHTTPClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        signHashClient = nil
        super.tearDown()
    }
    
    func testMakeRequestWithValidRequest() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        switch result {
        case .success(let response):
            XCTAssertNotNil(response, "Response should not be nil")
            XCTAssertNotNil(response.signatures, "Signatures should not be nil")
            XCTAssertEqual(response.signatures?.count, 1, "Should return one signature")
            XCTAssertEqual(response.signatures?[0], SignHashTestConstants.Responses.validSignHashResponse.signatures?[0], "Should return exact mocked signature")
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }
    
    func testMakeRequestWithMultipleHashes() async throws {
        let request = SignHashTestConstants.Requests.multipleHashesRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createMultipleSignaturesResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        switch result {
        case .success(let response):
            XCTAssertNotNil(response, "Response should not be nil")
            XCTAssertNotNil(response.signatures, "Signatures should not be nil")
            XCTAssertEqual(response.signatures?.count, 2, "Should return two signatures")
            XCTAssertEqual(response.signatures, SignHashTestConstants.Responses.multipleSignaturesResponse.signatures, "Should return exact mocked signatures")
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }

    func testRequestConstruction() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl

        let capturingMock = CapturingMockHTTPClient()
        let testClient = SignHashClient(httpClient: capturingMock)
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        capturingMock.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        _ = try await testClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)

        guard let capturedRequest = capturingMock.lastCapturedRequest else {
            XCTFail("No request was captured")
            return
        }
        
        XCTAssertEqual(capturedRequest.httpMethod, "POST", "Should use POST method")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer \(accessToken)", "Should set correct Authorization header")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json", "Should set correct Content-Type header")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Accept"), "application/json", "Should set correct Accept header")
    }
    
    func testMakeRequestWithNetworkError() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl

        let networkErrors = [
            URLError(.timedOut),
            URLError(.cannotConnectToHost),
            URLError(.networkConnectionLost),
            URLError(.notConnectedToInternet)
        ]
        
        for networkError in networkErrors {
            mockHTTPClient.setMockError(networkError)
            
            let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
            
            switch result {
            case .success:
                XCTFail("Should fail with network error: \(networkError)")
            case .failure(let error):
                XCTAssertEqual(error, ClientError.noData, "Should return noData for network error: \(networkError)")
            }

            mockHTTPClient.reset()
        }
    }
    
    func testMakeRequestWithServerError() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let errorResponseData = SignHashTestConstants.MockResponses.createErrorResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: errorResponseData, statusCode: 400)
        
        let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        switch result {
        case .success:
            XCTFail("Should fail with 400 status")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 400, "Should return 400 status code")
                XCTAssertTrue(message.contains("invalid_request"), "Should return error message")
            } else {
                XCTFail("Should return clientError with 400 status")
            }
        }
    }
    
    func testMakeRequestWithUnauthorizedAccess() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.expiredAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let unauthorizedResponseData = Data("Unauthorized".utf8)
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: unauthorizedResponseData, statusCode: 401)
        
        let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        switch result {
        case .success:
            XCTFail("Should fail with 401 status")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 401, "Should return 401 status code")
                XCTAssertEqual(message, "Unauthorized", "Should return unauthorized message")
            } else {
                XCTFail("Should return clientError with 401 status")
            }
        }
    }
    
    func testMakeRequestWithMalformedJSONResponse() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let malformedJSONData = Data("{ invalid json response }".utf8)
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: malformedJSONData)
        
        let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        switch result {
        case .success:
            XCTFail("Should fail with malformed JSON")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 200, "Should return 200 status code")
                XCTAssertTrue(message.contains("invalid json response"), "Should return malformed JSON as error message")
            } else {
                XCTFail("Should return clientError for malformed JSON")
            }
        }
    }
    
    func testMakeRequestWithDifferentStatusCodes() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let errorCodes = [403, 404, 500, 502, 503]
        
        for statusCode in errorCodes {
            let errorData = Data("Error \(statusCode)".utf8)
            mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: errorData, statusCode: statusCode)
            
            let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
            
            switch result {
            case .success:
                XCTFail("Should fail with \(statusCode) status")
            case .failure(let error):
                if case .clientError(let message, let returnedStatusCode) = error {
                    XCTAssertEqual(returnedStatusCode, statusCode, "Should return correct status code")
                    XCTAssertEqual(message, "Error \(statusCode)", "Should return error message")
                } else {
                    XCTFail("Should return clientError with \(statusCode) status")
                }
            }
        }
    }
    
    func testMakeRequestWithSuccessStatusCodes() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let successCodes = [200, 201, 299]
        
        for statusCode in successCodes {
            let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
            mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData, statusCode: statusCode)
            
            let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
            
            switch result {
            case .success(let response):
                XCTAssertNotNil(response, "Should succeed with \(statusCode) status")
                XCTAssertNotNil(response.signatures, "Signatures should not be nil")
                XCTAssertEqual(response.signatures?.count, 1, "Should return one signature")
            case .failure(let error):
                XCTFail("Should succeed with \(statusCode) status: \(error)")
            }
        }
    }
    
    func testMakeRequestJSONEncodingDecoding() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let result = try await signHashClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        switch result {
        case .success(let response):
            XCTAssertNotNil(response.signatures, "Signatures should not be nil")
            XCTAssertEqual(response.signatures?[0], "MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw=", "Should decode signature correctly")
            
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(request)
            let decodedRequest = try JSONDecoder().decode(SignHashRequest.self, from: encodedData)
            
            XCTAssertEqual(decodedRequest.operationMode, request.operationMode, "Should encode/decode operation mode correctly")
            XCTAssertEqual(decodedRequest.hashAlgorithmOID.rawValue, request.hashAlgorithmOID.rawValue, "Should encode/decode hash algorithm OID correctly")
            XCTAssertEqual(decodedRequest.hashes, request.hashes, "Should encode/decode hashes correctly")
            XCTAssertEqual(decodedRequest.signAlgo.rawValue, request.signAlgo.rawValue, "Should encode/decode sign algorithm correctly")
            XCTAssertEqual(decodedRequest.credentialID, request.credentialID, "Should encode/decode credential ID correctly")
            
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }
    
    func testMakeRequestAuthorizationHeaderHandling() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl

        let validAccessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let successResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: successResponseData)
        
        let validResult = try await signHashClient.makeRequest(for: request, accessToken: validAccessToken, rsspUrl: rsspUrl)
        
        switch validResult {
        case .success(let response):
            XCTAssertNotNil(response, "Should succeed with valid access token")
            XCTAssertNotNil(response.signatures, "Signatures should not be nil")
            XCTAssertEqual(response.signatures?.count, 1, "Should return signature with valid authorization")
        case .failure(let error):
            XCTFail("Should succeed with valid authorization: \(error)")
        }

        let expiredAccessToken = SignHashTestConstants.AccessTokens.expiredAccessToken
        let unauthorizedResponseData = Data("Unauthorized - Token expired".utf8)
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: unauthorizedResponseData, statusCode: 401)
        
        let expiredResult = try await signHashClient.makeRequest(for: request, accessToken: expiredAccessToken, rsspUrl: rsspUrl)
        
        switch expiredResult {
        case .success:
            XCTFail("Should fail with expired access token")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 401, "Should return 401 for expired token")
                XCTAssertTrue(message.contains("Unauthorized"), "Should contain unauthorized message")
            } else {
                XCTFail("Should return clientError for unauthorized access")
            }
        }

        let emptyAccessToken = ""
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: unauthorizedResponseData, statusCode: 401)
        
        let emptyResult = try await signHashClient.makeRequest(for: request, accessToken: emptyAccessToken, rsspUrl: rsspUrl)
        
        switch emptyResult {
        case .success:
            XCTFail("Should fail with empty access token")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 401, "Should return 401 for empty token")
                XCTAssertTrue(message.contains("Unauthorized"), "Should contain unauthorized message")
            } else {
                XCTFail("Should return clientError for empty authorization")
            }
        }
    }
} 
