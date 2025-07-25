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

final class OAuth2TokenTests: XCTestCase {
    
    var mockHTTPClient: CapturingMockHTTPClient!
    var oAuth2TokenClient: OAuth2TokenClient!
    var oAuth2TokenService: OAuth2TokenService!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = CapturingMockHTTPClient()
        oAuth2TokenClient = OAuth2TokenClient(httpClient: mockHTTPClient)
        oAuth2TokenService = OAuth2TokenService(client: oAuth2TokenClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        oAuth2TokenClient = nil
        oAuth2TokenService = nil
        super.tearDown()
    }

    func testMakeRequestSuccessfulServiceToken() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "XpOL_9gBQ4OczsEPvEL2atWb64WdvA_pCladM5ergCfegJD3RRXnqpqOBMCKNQ-RAAuoeynkSn6jE_fwFY5res9QmZJIC39z_k4G3-ZoIyJ2VZ13uPhQbJnoH4u_3DV0",
            state: "BB94593E-79FF-4BBE-8549-1A20E9D99677",
            auth: OAuth2TokenRequest.BasicAuth(username: "wallet-client", password: "somesecret2"),
            authorizationDetails: nil
        )
        
        let result = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response.accessToken, "eyJraWQiOiI1NmI1YjZmYi03N2JhLTRmY2QtODVlZi0yMjc3ZTA0MWI5ZDgiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI4UGZDQVF6VG1PTitGSER2SDRHVy9nK0pVdGc1ZVZUZ3RxTUtaRmRCLytjPSIsImF1ZCI6IndhbGxldC1jbGllbnQiLCJuYmYiOjE3NTM0OTA1NDAsInN1cm5hbWUiOiJNT2U5VFZSbEZ0YklVWVc2U1AzR0pvR2pCQURkaGRoTlF1R0crSXNxQnJwZDNjUVFGakk9IiwiaXNzdWluZ0NvdW50cnkiOiJGQyIsInNjb3BlIjpbInNlcnZpY2UiXSwiZ2l2ZW5OYW1lIjoiWHVOY3ExVGl3Ky9ubWg2SG5VaHR5M3ZoUGZHbDRKN281Z0VUSFR2b0sveXVrczFmbWc9PSIsImlzcyI6Imh0dHBzOi8vd2FsbGV0Y2VudHJpYy5zaWduZXIuZXVkaXcuZGV2IiwiZXhwIjoxNzUzNDkwODQwLCJpYXQiOjE3NTM0OTA1NDAsImp0aSI6ImMyZDQzYzNkLTYzMjgtNGE3NS1hMzA5LTdhYmNmZjgwYTRiMyJ9.c_ODfYYCuL5zhWzfcOPG2jrMRuPneoycGWBy25ljr_aw5R2w5j_B2m_AnIYCeTTxlBt2T47bqAONd6rfIdTgZjWcNnVCdVgqbtJ4a0z2qjdqZxL3bmvAduLWxXiM6qvwxLod0_6BPs4SF4Y1l7IAA8YS1T45pQYiUXioFmgxU1R1JxGh73mHa-YSoktuF7K5HLymJYXZQ7UbULm9WX1ZTxRSw48C2Gn1MSaxGj6NfVNdjLKR0F05gVzzCT84xqilcQifeYeefEPxzq429R5hrjuDf1Z02BfFIX4DDhgG2hJwZm9ZS1pstAus379iNQU-L_0x6eBqf5ML-3JJlDCcZA")
            XCTAssertEqual(response.tokenType, "Bearer")
            XCTAssertEqual(response.expiresIn, 3599)
            XCTAssertEqual(response.scope, "service")
        case .failure(let error):
            XCTFail("Expected successful response, but got error: \(error)")
        }
    }
    
    func testMakeRequestWithCredentialToken() async throws {
        let responseData = TestConstants.credentialAccessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "TjTlT5hNRGoIRgbiAklj8cK3bCwbhOlzMxTdx7f9ZlK-684vbBBrlKxRx3l6yKWGkuKEiiU19t9szlGkh1i3FwDbkw1qdOdOxj6XilNg7zm1D--TXrH_4oz7orcAge09",
            state: "BB94593E-79FF-4BBE-8549-1A20E9D99677",
            auth: OAuth2TokenRequest.BasicAuth(username: "wallet-client", password: "somesecret2"),
            authorizationDetails: nil
        )
        
        let result = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response.tokenType, "Bearer")
            XCTAssertEqual(response.expiresIn, 299)
            XCTAssertEqual(response.scope, "credential")
            XCTAssertTrue(response.accessToken.hasPrefix("eyJ"))
        case .failure(let error):
            XCTFail("Expected successful response, but got error: \(error)")
        }
    }
    
    func testMakeRequestWithoutAuth() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "test-code",
            state: "test-state",
            auth: nil,
            authorizationDetails: nil
        )
        
        let result = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response.tokenType, "Bearer")
            XCTAssertNotNil(response.accessToken)
        case .failure(let error):
            XCTFail("Expected successful response, but got error: \(error)")
        }

        let capturedRequest = mockHTTPClient.lastCapturedRequest
        XCTAssertNil(capturedRequest?.value(forHTTPHeaderField: "Authorization"))
    }
    
    func testMakeRequestFormBodyConstruction() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "test-client-id",
            redirectUri: "https://example.com/callback",
            grantType: "authorization_code",
            codeVerifier: "test-verifier-123",
            code: "auth-code-456",
            state: "state-789",
            auth: nil,
            authorizationDetails: nil
        )
        
        _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)

        let capturedRequest = mockHTTPClient.lastCapturedRequest
        guard let httpBody = capturedRequest?.httpBody,
              let bodyString = String(data: httpBody, encoding: .utf8) else {
            XCTFail("Request body should not be nil")
            return
        }

        XCTAssertTrue(bodyString.contains("grant_type=authorization_code"))
        XCTAssertTrue(bodyString.contains("client_id=test-client-id"))
        XCTAssertTrue(bodyString.contains("code=auth-code-456"))
        XCTAssertTrue(bodyString.contains("state=state-789"))
        XCTAssertTrue(bodyString.contains("code_verifier=test-verifier-123"))
        XCTAssertTrue(bodyString.contains("redirect_uri="))
    }
    
    func testMakeRequestBasicAuthenticationEncoding() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "code",
            state: "state",
            auth: OAuth2TokenRequest.BasicAuth(username: "user123", password: "pass456"),
            authorizationDetails: nil
        )
        
        _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)

        let capturedRequest = mockHTTPClient.lastCapturedRequest
        let authHeader = capturedRequest?.value(forHTTPHeaderField: "Authorization")
        
        XCTAssertNotNil(authHeader)
        XCTAssertTrue(authHeader?.hasPrefix("Basic ") ?? false)

        if let authHeader = authHeader,
           let base64Part = authHeader.components(separatedBy: " ").last,
           let decodedData = Data(base64Encoded: base64Part),
           let decodedString = String(data: decodedData, encoding: .utf8) {
            XCTAssertEqual(decodedString, "user123:pass456")
        } else {
            XCTFail("Could not decode Basic Auth header")
        }
    }
    
    func testMakeRequestHTTPMethodAndHeaders() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)

        let capturedRequest = mockHTTPClient.lastCapturedRequest
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
        XCTAssertNotNil(capturedRequest?.httpBody)
    }
    
    func testMakeRequestURLConstruction() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)

        let capturedRequest = mockHTTPClient.lastCapturedRequest
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://walletcentric.signer.eudiw.dev/oauth2/token")
        XCTAssertEqual(capturedRequest?.url?.path, "/oauth2/token")
        XCTAssertEqual(capturedRequest?.url?.host, "walletcentric.signer.eudiw.dev")
        XCTAssertEqual(capturedRequest?.url?.scheme, "https")
    }
    
    func testMakeRequestNonHTTPResponse() async throws {
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: Data(), statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        do {
            _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        } catch {
            XCTAssertTrue(error is ClientError)
        }
    }
    
    func testMakeRequestBasicAuthWithSpecialCharacters() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "code",
            state: "state",
            auth: OAuth2TokenRequest.BasicAuth(username: "user@domain.com", password: "p@ss:w0rd!"),
            authorizationDetails: nil
        )
        
        _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        let capturedRequest = mockHTTPClient.lastCapturedRequest
        let authHeader = capturedRequest?.value(forHTTPHeaderField: "Authorization")
        
        XCTAssertNotNil(authHeader)
        XCTAssertTrue(authHeader?.hasPrefix("Basic ") ?? false)
        
        if let authHeader = authHeader,
           let base64Part = authHeader.components(separatedBy: " ").last,
           let decodedData = Data(base64Encoded: base64Part),
           let decodedString = String(data: decodedData, encoding: .utf8) {
            XCTAssertEqual(decodedString, "user@domain.com:p@ss:w0rd!")
        } else {
            XCTFail("Could not decode Basic Auth header with special characters")
        }
    }
    
    func testMakeRequestWithHTTPError() async throws {
        let errorResponseData = TestConstants.oAuth2ErrorResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: errorResponseData, statusCode: 400)
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "invalid-code",
            state: "test-state",
            auth: OAuth2TokenRequest.BasicAuth(username: "wallet-client", password: "somesecret2"),
            authorizationDetails: nil
        )
        
        let result = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        
        switch result {
        case .success:
            XCTFail("Expected failure for HTTP error")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 400)
                XCTAssertTrue(message.contains("invalid_grant"))
            } else {
                XCTFail("Expected ClientError.clientError, got \(error)")
            }
        }
    }
    
    func testMakeRequestWithNetworkError() async throws {
        mockHTTPClient.setMockError(URLError(.networkConnectionLost))
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "test-code",
            state: "test-state",
            auth: nil,
            authorizationDetails: nil
        )
        
        do {
            _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
            XCTFail("Expected network error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
    
    func testMakeRequestVerifiesHeaders() async throws {
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "test-code",
            state: "test-state",
            auth: OAuth2TokenRequest.BasicAuth(username: "wallet-client", password: "somesecret2"),
            authorizationDetails: nil
        )
        
        _ = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        
        let capturedRequest = mockHTTPClient.lastCapturedRequest
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
        XCTAssertNotNil(capturedRequest?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertTrue(capturedRequest?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Basic ") ?? false)
    }
    
    func testMakeRequestWithInvalidJSONResponse() async throws {
        let invalidResponseData = TestConstants.invalidJSONResponse.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: invalidResponseData, statusCode: 200)
        
        let request = OAuth2TokenRequest(
            clientId: "wallet-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: TestConstants.testCodeVerifier,
            code: "test-code",
            state: "test-state",
            auth: nil,
            authorizationDetails: nil
        )
        
        let result = try await oAuth2TokenClient.makeRequest(for: request, issuerURL: TestConstants.testIssuerURL)
        
        switch result {
        case .success:
            XCTFail("Expected failure for invalid JSON response")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 200)
                XCTAssertTrue(message.contains("invalid"))
            } else {
                XCTFail("Expected ClientError.clientError, got \(error)")
            }
        }
    }

    func testGetTokenSuccessful() async throws {
        await PKCEState.shared.reset()
        _ = try await PKCEState.shared.initializeAndGetCodeChallenge()
        
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        let response = try await oAuth2TokenService.getToken(
            request: TestConstants.serviceAccessTokenRequest,
            cscClientConfig: TestConstants.testCSCClientConfig,
            issuerURL: TestConstants.testIssuerURL
        )
        
        XCTAssertEqual(response.accessToken, "eyJraWQiOiI1NmI1YjZmYi03N2JhLTRmY2QtODVlZi0yMjc3ZTA0MWI5ZDgiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI4UGZDQVF6VG1PTitGSER2SDRHVy9nK0pVdGc1ZVZUZ3RxTUtaRmRCLytjPSIsImF1ZCI6IndhbGxldC1jbGllbnQiLCJuYmYiOjE3NTM0OTA1NDAsInN1cm5hbWUiOiJNT2U5VFZSbEZ0YklVWVc2U1AzR0pvR2pCQURkaGRoTlF1R0crSXNxQnJwZDNjUVFGakk9IiwiaXNzdWluZ0NvdW50cnkiOiJGQyIsInNjb3BlIjpbInNlcnZpY2UiXSwiZ2l2ZW5OYW1lIjoiWHVOY3ExVGl3Ky9ubWg2SG5VaHR5M3ZoUGZHbDRKN281Z0VUSFR2b0sveXVrczFmbWc9PSIsImlzcyI6Imh0dHBzOi8vd2FsbGV0Y2VudHJpYy5zaWduZXIuZXVkaXcuZGV2IiwiZXhwIjoxNzUzNDkwODQwLCJpYXQiOjE3NTM0OTA1NDAsImp0aSI6ImMyZDQzYzNkLTYzMjgtNGE3NS1hMzA5LTdhYmNmZjgwYTRiMyJ9.c_ODfYYCuL5zhWzfcOPG2jrMRuPneoycGWBy25ljr_aw5R2w5j_B2m_AnIYCeTTxlBt2T47bqAONd6rfIdTgZjWcNnVCdVgqbtJ4a0z2qjdqZxL3bmvAduLWxXiM6qvwxLod0_6BPs4SF4Y1l7IAA8YS1T45pQYiUXioFmgxU1R1JxGh73mHa-YSoktuF7K5HLymJYXZQ7UbULm9WX1ZTxRSw48C2Gn1MSaxGj6NfVNdjLKR0F05gVzzCT84xqilcQifeYeefEPxzq429R5hrjuDf1Z02BfFIX4DDhgG2hJwZm9ZS1pstAus379iNQU-L_0x6eBqf5ML-3JJlDCcZA")
        XCTAssertEqual(response.tokenType, "Bearer")
        XCTAssertEqual(response.expiresIn, 3599)
        XCTAssertEqual(response.scope, "service")

        let verifierAfterExchange = await PKCEState.shared.getVerifier()
        XCTAssertNil(verifierAfterExchange, "PKCE state should be reset after successful token exchange")
    }
    
    func testGetTokenWithCredentialScope() async throws {
        await PKCEState.shared.reset()
        _ = try await PKCEState.shared.initializeAndGetCodeChallenge()
        
        let responseData = TestConstants.credentialAccessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)

        let simpleCredentialRequest = AccessTokenRequest(
            code: "TjTlT5hNRGoIRgbiAklj8cK3bCwbhOlzMxTdx7f9ZlK-684vbBBrlKxRx3l6yKWGkuKEiiU19t9szlGkh1i3FwDbkw1qdOdOxj6XilNg7zm1D--TXrH_4oz7orcAge09",
            state: "BB94593E-79FF-4BBE-8549-1A20E9D99677",
            authorizationDetails: nil
        )
        
        let response = try await oAuth2TokenService.getToken(
            request: simpleCredentialRequest,
            cscClientConfig: TestConstants.testCSCClientConfig,
            issuerURL: TestConstants.testIssuerURL
        )
        
        XCTAssertEqual(response.tokenType, "Bearer")
        XCTAssertEqual(response.expiresIn, 299)
        XCTAssertEqual(response.scope, "credential")
        XCTAssertTrue(response.accessToken.hasPrefix("eyJ"))
    }
    
    func testGetTokenWithMissingPKCEVerifier() async throws {
        await PKCEState.shared.reset()
        
        do {
            _ = try await oAuth2TokenService.getToken(
                request: TestConstants.serviceAccessTokenRequest,
                cscClientConfig: TestConstants.testCSCClientConfig,
                issuerURL: TestConstants.testIssuerURL
            )
            XCTFail("Expected missing PKCE verifier error")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "PKCEError")
            XCTAssertEqual(nsError.code, 1)
            XCTAssertTrue(nsError.localizedDescription.contains("Code verifier is missing"))
        }
    }
    
    func testGetTokenCorrectOAuth2TokenRequestUsage() async throws {
        await PKCEState.shared.reset()
        _ = try await PKCEState.shared.initializeAndGetCodeChallenge()
        
        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)
        
        _ = try await oAuth2TokenService.getToken(
            request: TestConstants.serviceAccessTokenRequest,
            cscClientConfig: TestConstants.testCSCClientConfig,
            issuerURL: TestConstants.testIssuerURL
        )

        let capturedRequest = mockHTTPClient.lastCapturedRequest
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")

        if let httpBody = capturedRequest?.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            XCTAssertTrue(bodyString.contains("grant_type=authorization_code"))
            XCTAssertTrue(bodyString.contains("client_id=wallet-client"))
            XCTAssertTrue(bodyString.contains("code_verifier="))
        }
    }
    
    func testGetTokenWithClientError() async throws {
        await PKCEState.shared.reset()
        _ = try await PKCEState.shared.initializeAndGetCodeChallenge()
        
        let errorResponseData = TestConstants.oAuth2ErrorResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: errorResponseData, statusCode: 400)
        
        do {
            _ = try await oAuth2TokenService.getToken(
                request: TestConstants.serviceAccessTokenRequest,
                cscClientConfig: TestConstants.testCSCClientConfig,
                issuerURL: TestConstants.testIssuerURL
            )
            XCTFail("Expected client error to be thrown")
        } catch {
            XCTAssertTrue(error is ClientError)
            if case .clientError(let message, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 400)
                XCTAssertTrue(message.contains("invalid_grant"))
            }
        }

        let verifierAfterError = await PKCEState.shared.getVerifier()
        XCTAssertNil(verifierAfterError, "PKCE state should be reset when client returns Result.failure")
    }
    
    func testGetTokenPKCEIntegration() async throws {
        await PKCEState.shared.reset()

        let challenge = try await PKCEState.shared.initializeAndGetCodeChallenge()
        let verifierBeforeExchange = await PKCEState.shared.getVerifier()
        
        XCTAssertNotNil(challenge)
        XCTAssertNotNil(verifierBeforeExchange)

        let responseData = TestConstants.accessTokenResponseJSON.data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "https://walletcentric.signer.eudiw.dev/oauth2/token", data: responseData, statusCode: 200)

        _ = try await oAuth2TokenService.getToken(
            request: TestConstants.serviceAccessTokenRequest,
            cscClientConfig: TestConstants.testCSCClientConfig,
            issuerURL: TestConstants.testIssuerURL
        )

        let verifierAfterExchange = await PKCEState.shared.getVerifier()
        XCTAssertNil(verifierAfterExchange, "PKCE verifier should be cleared after token exchange")
    }
    
    func testGetTokenWithNetworkError() async throws {
        await PKCEState.shared.reset()
        _ = try await PKCEState.shared.initializeAndGetCodeChallenge()
        let verifierBeforeCall = await PKCEState.shared.getVerifier()
        XCTAssertNotNil(verifierBeforeCall, "PKCE verifier should be set before network call")
        
        mockHTTPClient.setMockError(URLError(.networkConnectionLost))
        
        do {
            _ = try await oAuth2TokenService.getToken(
                request: TestConstants.serviceAccessTokenRequest,
                cscClientConfig: TestConstants.testCSCClientConfig,
                issuerURL: TestConstants.testIssuerURL
            )
            XCTFail("Expected network error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
        let verifierAfterError = await PKCEState.shared.getVerifier()
        XCTAssertNotNil(verifierAfterError, "PKCE state should remain when network error prevents service completion")
        XCTAssertEqual(verifierAfterError, verifierBeforeCall, "PKCE verifier should be unchanged after network error")
    }

    func testClientErrorEquality() {
        let error1 = ClientError.invalidRequestURL
        let error2 = ClientError.invalidRequestURL
        let error3 = ClientError.invalidResponse
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
        
        let clientError1 = ClientError.clientError(message: "Test error", statusCode: 400)
        let clientError2 = ClientError.clientError(message: "Test error", statusCode: 400)
        let clientError3 = ClientError.clientError(message: "Different error", statusCode: 400)
        let clientError4 = ClientError.clientError(message: "Test error", statusCode: 500)
        
        XCTAssertEqual(clientError1, clientError2)
        XCTAssertNotEqual(clientError1, clientError3)
        XCTAssertNotEqual(clientError1, clientError4)
    }
    
    func testClientErrorDescriptions() {
        let invalidURL = ClientError.invalidRequestURL
        XCTAssertEqual(invalidURL.errorDescription, "The request URL is invalid.")
        
        let invalidResponse = ClientError.invalidResponse
        XCTAssertEqual(invalidResponse.errorDescription, "The response was invalid.")
        
        let encodingFailed = ClientError.encodingFailed
        XCTAssertEqual(encodingFailed.errorDescription, "Failed to encode the request.")
        
        let clientError = ClientError.clientError(message: "Invalid credentials", statusCode: 401)
        XCTAssertEqual(clientError.errorDescription, "Server response (status code 401): Invalid credentials")
        
        let httpError = ClientError.httpError(statusCode: 500)
        XCTAssertEqual(httpError.errorDescription, "HTTP error with status code 500.")
        
        let noData = ClientError.noData
        XCTAssertEqual(noData.errorDescription, "No data was returned by the server.")
        
        let decodingError = ClientError.responseDecodingError
        XCTAssertEqual(decodingError.errorDescription, "Failed to decode the server response.")
    }
    
    func testClientErrorAsLocalizedError() {
        let error: LocalizedError = ClientError.invalidRequestURL
        XCTAssertNotNil(error.errorDescription)
        XCTAssertEqual(error.errorDescription, "The request URL is invalid.")
        
        let clientError: LocalizedError = ClientError.clientError(message: "Test", statusCode: 400)
        XCTAssertTrue(clientError.errorDescription?.contains("Server response") ?? false)
        XCTAssertTrue(clientError.errorDescription?.contains("400") ?? false)
        XCTAssertTrue(clientError.errorDescription?.contains("Test") ?? false)
    }

    func testOAuth2TokenErrorDescriptions() {
        let missingClientId = OAuth2TokenError.missingClientId
        XCTAssertEqual(missingClientId.errorDescription, "The client_id is required.")
        
        let missingGrantType = OAuth2TokenError.missingGrantType
        XCTAssertEqual(missingGrantType.errorDescription, "The grant_type is required.")
        
        let missingRedirectUri = OAuth2TokenError.missingRedirectUri
        XCTAssertEqual(missingRedirectUri.errorDescription, "The redirect_uri is required for authorization_code grant type.")
    }
    
    func testOAuth2TokenErrorAsLocalizedError() {
        let error: LocalizedError = OAuth2TokenError.missingClientId
        XCTAssertNotNil(error.errorDescription)
        XCTAssertEqual(error.errorDescription, "The client_id is required.")
        
        let error2: LocalizedError = OAuth2TokenError.missingGrantType
        XCTAssertTrue(error2.errorDescription?.contains("grant_type") ?? false)
        
        let error3: LocalizedError = OAuth2TokenError.missingRedirectUri
        XCTAssertTrue(error3.errorDescription?.contains("redirect_uri") ?? false)
        XCTAssertTrue(error3.errorDescription?.contains("authorization_code") ?? false)
    }

    func testValidateValidRequest() throws {
        let validRequest = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "https://example.com/callback",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )

        XCTAssertNoThrow(try OAuth2TokenValidator.validate(validRequest))
    }
    
    func testValidateMissingClientId() {
        let invalidRequest = OAuth2TokenRequest(
            clientId: "",
            redirectUri: "https://example.com/callback",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        XCTAssertThrowsError(try OAuth2TokenValidator.validate(invalidRequest)) { error in
            XCTAssertTrue(error is OAuth2TokenError)
            if case OAuth2TokenError.missingClientId = error {
            } else {
                XCTFail("Expected OAuth2TokenError.missingClientId, got \(error)")
            }
        }
    }
    
    func testValidateMissingGrantType() {
        let invalidRequest = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "https://example.com/callback",
            grantType: "",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        XCTAssertThrowsError(try OAuth2TokenValidator.validate(invalidRequest)) { error in
            XCTAssertTrue(error is OAuth2TokenError)
            if case OAuth2TokenError.missingGrantType = error {
            } else {
                XCTFail("Expected OAuth2TokenError.missingGrantType, got \(error)")
            }
        }
    }
    
    func testValidateMissingRedirectUriForAuthorizationCode() {
        let invalidRequest = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        XCTAssertThrowsError(try OAuth2TokenValidator.validate(invalidRequest)) { error in
            XCTAssertTrue(error is OAuth2TokenError)
            if case OAuth2TokenError.missingRedirectUri = error {
            } else {
                XCTFail("Expected OAuth2TokenError.missingRedirectUri, got \(error)")
            }
        }
    }
    
    func testValidateNonAuthorizationCodeGrantType() throws {
        let validRequest = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "",
            grantType: "client_credentials",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )

        XCTAssertNoThrow(try OAuth2TokenValidator.validate(validRequest))
    }
    
    func testValidateAuthorizationCodeWithRedirectUri() throws {
        let validRequest = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "https://example.com/callback",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )

        XCTAssertNoThrow(try OAuth2TokenValidator.validate(validRequest))
    }
    
    func testValidateMultipleValidationErrors() {
        let invalidRequest = OAuth2TokenRequest(
            clientId: "",
            redirectUri: "",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "auth-code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        XCTAssertThrowsError(try OAuth2TokenValidator.validate(invalidRequest)) { error in
            XCTAssertTrue(error is OAuth2TokenError)
            if case OAuth2TokenError.missingClientId = error {
            } else {
                XCTFail("Expected OAuth2TokenError.missingClientId (first error), got \(error)")
            }
        }
    }
    
    func testValidatorProtocolConformance() {
        let validRequest = OAuth2TokenRequest(
            clientId: "test-client",
            redirectUri: "https://example.com",
            grantType: "authorization_code",
            codeVerifier: "verifier",
            code: "code",
            state: "state",
            auth: nil,
            authorizationDetails: nil
        )
        
        XCTAssertNoThrow(try OAuth2TokenValidator.validate(validRequest))

        let input: OAuth2TokenValidator.Input = validRequest
        XCTAssertEqual(input.clientId, "test-client")
        XCTAssertEqual(input.grantType, "authorization_code")
    }
}
