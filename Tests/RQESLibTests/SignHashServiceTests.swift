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

final class SignHashServiceTests: XCTestCase {
    
    var signHashService: SignHashService!
    var mockHTTPClient: MockHTTPClient!
    var signHashClient: SignHashClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        signHashClient = SignHashClient(httpClient: mockHTTPClient)
        signHashService = SignHashService(signHashClient: signHashClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        signHashClient = nil
        signHashService = nil
        super.tearDown()
    }
    
    func testSignHashWithValidRequest() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let response = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertNotNil(response.signatures, "Signatures should not be nil")
        XCTAssertEqual(response.signatures?.count, 1, "Should return one signature")
        XCTAssertEqual(response.signatures?[0], SignHashTestConstants.Responses.validSignHashResponse.signatures?[0], "Should return exact mocked signature")
    }
    
    func testSignHashWithMultipleHashes() async throws {
        let request = SignHashTestConstants.Requests.multipleHashesRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createMultipleSignaturesResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let response = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertNotNil(response.signatures, "Signatures should not be nil")
        XCTAssertEqual(response.signatures?.count, 2, "Should return two signatures for two hashes")
        XCTAssertEqual(response.signatures, SignHashTestConstants.Responses.multipleSignaturesResponse.signatures, "Should return exact mocked signatures")
    }
    
    func testSignHashWithValidationErrors() async {
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl

        let missingCredentialIDRequest = SignHashRequest(
            credentialID: "",
            hashes: ["hash"],
            hashAlgorithmOID: .SHA256,
            signAlgo: .ECDSA,
            operationMode: "S"
        )
        
        do {
            _ = try await signHashService.signHash(request: missingCredentialIDRequest, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw validation error for missing credential ID")
        } catch let error as SignHashError where error == .missingCredentialID {
            XCTAssertEqual(error.localizedDescription, "Missing 'credentialID' parameter. The 'credentialID' parameter is required.")
        } catch {
            XCTFail("Should throw SignHashError.missingCredentialID, got \(error)")
        }

        let missingHashesRequest = SignHashRequest(
            credentialID: "valid-id",
            hashes: [],
            hashAlgorithmOID: .SHA256,
            signAlgo: .ECDSA,
            operationMode: "S"
        )
        
        do {
            _ = try await signHashService.signHash(request: missingHashesRequest, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw validation error for missing hashes")
        } catch let error as SignHashError where error == .missingHashes {
            XCTAssertEqual(error.localizedDescription, "Missing or invalid 'hashes' parameter. At least one hash value is required.")
        } catch {
            XCTFail("Should throw SignHashError.missingHashes, got \(error)")
        }
    }
    
    func testSignHashWithNetworkError() async {
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
            
            do {
                _ = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
                XCTFail("Should throw error for network error: \(networkError)")
            } catch {
                XCTAssertTrue(error is ClientError, "Should throw ClientError for network error: \(networkError)")
            }

            mockHTTPClient.reset()
        }
    }
    
    func testSignHashWithServerError() async {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let errorResponseData = SignHashTestConstants.MockResponses.createErrorResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: errorResponseData, statusCode: 400)
        
        do {
            _ = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw error for 400 status")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError for server error")
            if case .clientError(let message, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 400, "Should return 400 status code")
                XCTAssertTrue(message.contains("invalid_request"), "Should return error message")
            }
        }
    }
    
    func testSignHashWithUnauthorizedAccess() async {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.expiredAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let unauthorizedResponseData = Data("Unauthorized".utf8)
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: unauthorizedResponseData, statusCode: 401)
        
        do {
            _ = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw error for 401 status")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError for unauthorized access")
            if case .clientError(let message, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 401, "Should return 401 status code")
                XCTAssertEqual(message, "Unauthorized", "Should return unauthorized message")
            }
        }
    }

    func testSignHashServiceValidationBeforeHTTPCall() async {
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl

        let invalidRequest = SignHashRequest(
            credentialID: "",
            hashes: [],
            hashAlgorithmOID: .SHA256,
            signAlgo: .ECDSA,
            operationMode: "S"
        )

        do {
            _ = try await signHashService.signHash(request: invalidRequest, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw validation error before making HTTP call")
        } catch let error as SignHashError where error == .missingCredentialID {
            XCTAssertEqual(error.localizedDescription, "Missing 'credentialID' parameter. The 'credentialID' parameter is required.")
        } catch {
            XCTFail("Should throw SignHashError.missingCredentialID for validation, got \(error)")
        }
    }
    
    func testSignHashIntegrationWithRealDataFlow() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let response = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertNotNil(response.signatures, "Signatures should not be nil")
        XCTAssertFalse(response.signatures?.isEmpty ?? true, "Should contain at least one signature")
        
        let expectedSignature = "MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw="
        XCTAssertEqual(response.signatures?[0], expectedSignature, "Should return the exact signature from real data")
        
        XCTAssertEqual(response.signatures?.count, request.hashes.count, "Number of signatures should match number of hashes")
        
        if let signatures = response.signatures {
            for signature in signatures {
                XCTAssertFalse(signature.isEmpty, "Each signature should not be empty")
                XCTAssertTrue(signature.count > 20, "Each signature should be substantial")
            }
        }
    }
    
    func testSignHashRequestResponseValidation() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let response = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        XCTAssertEqual(request.operationMode, "S", "Should have correct operation mode")
        XCTAssertEqual(request.hashAlgorithmOID.rawValue, HashAlgorithmOID.SHA256.rawValue, "Should have SHA256 algorithm OID")
        XCTAssertEqual(request.signAlgo.rawValue, SigningAlgorithmOID.ECDSA.rawValue, "Should have ECDSA signing algorithm OID")
        XCTAssertEqual(request.credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85", "Should have correct credential ID")
        XCTAssertEqual(request.hashes.count, 1, "Should have one hash")
        XCTAssertEqual(request.hashes[0], "gA6NvbA7MA5BwMOG7KPcM7kA74Xd1OrdoM6A9AoRlAqH9MEbNyTNGbox6T3fc8kcHITYsKkA8KLcZmkTimg3DK3D", "Should have correct hash value")
        
        XCTAssertNotNil(response.signatures, "Signatures should not be nil")
        XCTAssertEqual(response.signatures?.count, 1, "Should return one signature")
        XCTAssertEqual(response.signatures?[0], "MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw=", "Should return correct signature")
    }
    
    func testSignHashServiceWithDifferentAlgorithms() async throws {
        let algorithms = [
            (HashAlgorithmOID.SHA256, "SHA256"),
            (HashAlgorithmOID.SHA385, "SHA384"),
            (HashAlgorithmOID.SHA512, "SHA512")
        ]
        
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        for (algorithmOID, algorithmName) in algorithms {
            let request = SignHashRequest(
                credentialID: "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
                hashes: ["gA6NvbA7MA5BwMOG7KPcM7kA74Xd1OrdoM6A9AoRlAqH9MEbNyTNGbox6T3fc8kcHITYsKkA8KLcZmkTimg3DK3D"],
                hashAlgorithmOID: algorithmOID,
                signAlgo: .ECDSA,
                operationMode: "S"
            )
            
            let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
            mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
            
            let response = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
            
            XCTAssertNotNil(response, "Should succeed with \(algorithmName) algorithm")
            XCTAssertNotNil(response.signatures, "Signatures should not be nil")
            XCTAssertEqual(response.signatures?.count, 1, "Should return one signature for \(algorithmName)")
            XCTAssertEqual(request.hashAlgorithmOID.rawValue, algorithmOID.rawValue, "Should use \(algorithmName) algorithm OID")
        }
    }
    
    func testSignHashServiceValidationIntegration() async throws {
        let request = SignHashTestConstants.Requests.validSignHashRequest
        let accessToken = SignHashTestConstants.AccessTokens.validAccessToken
        let rsspUrl = SignHashTestConstants.URLs.rsspUrl
        
        let mockResponseData = SignHashTestConstants.MockResponses.createValidSignHashResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: SignHashTestConstants.URLs.fullSignHashUrl, data: mockResponseData)
        
        let response = try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: rsspUrl)
        
        XCTAssertNotNil(response, "Validation should pass for valid request")

        mockHTTPClient.reset()

        let missingHashesRequest = SignHashRequest(
            credentialID: "valid-id", 
            hashes: [], 
            hashAlgorithmOID: .SHA256, 
            signAlgo: .ECDSA, 
            operationMode: "S"
        )
        
        do {
            _ = try await signHashService.signHash(request: missingHashesRequest, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw validation error for missing hashes")
        } catch let error as SignHashError where error == .missingHashes {
            XCTAssertEqual(error.localizedDescription, "Missing or invalid 'hashes' parameter. At least one hash value is required.")
        } catch {
            XCTFail("Should throw SignHashError.missingHashes for empty hashes, got \(error)")
        }

        let missingCredentialIDRequest = SignHashRequest(
            credentialID: "", 
            hashes: ["valid-hash"], 
            hashAlgorithmOID: .SHA256, 
            signAlgo: .ECDSA, 
            operationMode: "S"
        )
        
        do {
            _ = try await signHashService.signHash(request: missingCredentialIDRequest, accessToken: accessToken, rsspUrl: rsspUrl)
            XCTFail("Should throw validation error for missing credential ID")
        } catch let error as SignHashError where error == .missingCredentialID {
            XCTAssertEqual(error.localizedDescription, "Missing 'credentialID' parameter. The 'credentialID' parameter is required.")
        } catch {
            XCTFail("Should throw SignHashError.missingCredentialID for empty credential ID, got \(error)")
        }
    }
} 
