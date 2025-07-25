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

final class AuthorizationFlowTests: XCTestCase {

    func testAuthorizationPrepareResponseInitialization() {
        let authorizationURL = TestConstants.serviceAuthorizationURL
        let response = AuthorizationPrepareResponse(authorizationCodeURL: authorizationURL)
        
        XCTAssertEqual(response.authorizationCodeURL, authorizationURL)
    }
    
    func testAuthorizationPrepareResponseCodable() throws {
        let authorizationURL = TestConstants.credentialAuthorizationURL
        let response = AuthorizationPrepareResponse(authorizationCodeURL: authorizationURL)

        let encoder = JSONEncoder()
        let data = try encoder.encode(response)

        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(AuthorizationPrepareResponse.self, from: data)
        
        XCTAssertEqual(decodedResponse.authorizationCodeURL, authorizationURL)
    }
    
    func testAuthorizationPrepareResponseJSONKeys() throws {
        let authorizationURL = "https://example.com/oauth2/authorize"
        let response = AuthorizationPrepareResponse(authorizationCodeURL: authorizationURL)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["authorization_code_url"] as? String, authorizationURL)
        XCTAssertNil(json?["authorizationCodeURL"])
    }

    func testDocumentDigestInitialization() {
        let digest = TestConstants.testDocumentDigest
        
        XCTAssertEqual(digest.label, "A sample1 pdf")
        XCTAssertEqual(digest.hash, TestConstants.urlEncodedHash)
    }
    
    func testDocumentDigestCodable() throws {
        let digest = DocumentDigest(label: "test.pdf", hash: "abcd1234")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(digest)
        
        let decoder = JSONDecoder()
        let decodedDigest = try decoder.decode(DocumentDigest.self, from: data)
        
        XCTAssertEqual(decodedDigest.label, "test.pdf")
        XCTAssertEqual(decodedDigest.hash, "abcd1234")
    }
    
    func testDocumentDigestFromRealisticData() throws {
        let jsonString = """
        {
            "label": "A sample1 pdf",
            "hash": "lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let digest = try decoder.decode(DocumentDigest.self, from: data)
        
        XCTAssertEqual(digest.label, "A sample1 pdf")
        XCTAssertEqual(digest.hash, TestConstants.urlEncodedHash)
    }

    func testAuthorizationDetailsItemInitialization() {
        let item = TestConstants.testAuthorizationDetailsItem
        
        XCTAssertEqual(item.credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
        XCTAssertEqual(item.hashAlgorithmOID.rawValue, HashAlgorithmOID.SHA256.rawValue)
        XCTAssertEqual(item.type, "credential")
        XCTAssertTrue(item.locations.isEmpty)
        XCTAssertEqual(item.documentDigests.count, 1)
        XCTAssertEqual(item.documentDigests[0].label, "A sample1 pdf")
    }
    
    func testAuthorizationDetailsItemCodable() throws {
        let item = AuthorizationDetailsItem(
            documentDigests: [DocumentDigest(label: "test.pdf", hash: "hash123")],
            credentialID: "test-credential-id",
            hashAlgorithmOID: HashAlgorithmOID.SHA256,
            locations: ["location1"],
            type: "credential"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(AuthorizationDetailsItem.self, from: data)
        
        XCTAssertEqual(decodedItem.credentialID, "test-credential-id")
        XCTAssertEqual(decodedItem.hashAlgorithmOID.rawValue, HashAlgorithmOID.SHA256.rawValue)
        XCTAssertEqual(decodedItem.type, "credential")
        XCTAssertEqual(decodedItem.locations, ["location1"])
        XCTAssertEqual(decodedItem.documentDigests.count, 1)
    }
    
    func testAuthorizationDetailsItemFromRealisticData() throws {
        let jsonString = """
        {
            "type": "credential",
            "hashAlgorithmOID": "2.16.840.1.101.3.4.2.1",
            "documentDigests": [
                {
                    "label": "A sample1 pdf",
                    "hash": "lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D"
                }
            ],
            "credentialID": "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
            "locations": []
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let item = try decoder.decode(AuthorizationDetailsItem.self, from: data)
        
        XCTAssertEqual(item.type, "credential")
        XCTAssertEqual(item.hashAlgorithmOID.rawValue, "2.16.840.1.101.3.4.2.1")
        XCTAssertEqual(item.credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
        XCTAssertTrue(item.locations.isEmpty)
        XCTAssertEqual(item.documentDigests.count, 1)
        XCTAssertEqual(item.documentDigests[0].label, "A sample1 pdf")
    }

    func testAuthorizationDetailsArrayCodable() throws {
        let details = TestConstants.testAuthorizationDetails
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(details)
        
        let decoder = JSONDecoder()
        let decodedDetails = try decoder.decode(AuthorizationDetails.self, from: data)
        
        XCTAssertEqual(decodedDetails.count, 1)
        XCTAssertEqual(decodedDetails[0].credentialID, "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85")
    }
    
    func testAuthorizationDetailsMultipleItems() throws {
        let item1 = AuthorizationDetailsItem(
            documentDigests: [DocumentDigest(label: "doc1.pdf", hash: "hash1")],
            credentialID: "cred-1",
            hashAlgorithmOID: HashAlgorithmOID.SHA256,
            locations: [],
            type: "credential"
        )
        
        let item2 = AuthorizationDetailsItem(
            documentDigests: [DocumentDigest(label: "doc2.pdf", hash: "hash2")],
            credentialID: "cred-2",
            hashAlgorithmOID: HashAlgorithmOID.SHA512,
            locations: ["location1"],
            type: "credential"
        )
        
        let details: AuthorizationDetails = [item1, item2]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(details)
        
        let decoder = JSONDecoder()
        let decodedDetails = try decoder.decode(AuthorizationDetails.self, from: data)
        
        XCTAssertEqual(decodedDetails.count, 2)
        XCTAssertEqual(decodedDetails[0].credentialID, "cred-1")
        XCTAssertEqual(decodedDetails[1].credentialID, "cred-2")
        XCTAssertEqual(decodedDetails[0].hashAlgorithmOID.rawValue, HashAlgorithmOID.SHA256.rawValue)
        XCTAssertEqual(decodedDetails[1].hashAlgorithmOID.rawValue, HashAlgorithmOID.SHA512.rawValue)
    }

    func testPrepareServiceRequestSuccess() async throws {
        let service = PrepareAuthorizationRequestService()
        let walletState = TestConstants.walletState
        let cscClientConfig = TestConstants.testCSCClientConfig
        let issuerURL = TestConstants.testIssuerURL
        
        let response = try await service.prepareServiceRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            issuerURL: issuerURL
        )
        
        XCTAssertFalse(response.authorizationCodeURL.isEmpty)
        XCTAssertTrue(response.authorizationCodeURL.contains("response_type=code"))
        XCTAssertTrue(response.authorizationCodeURL.contains("client_id=wallet-client"))
        XCTAssertTrue(response.authorizationCodeURL.contains("scope=service"))
        XCTAssertTrue(response.authorizationCodeURL.contains("state=\(walletState)"))
        XCTAssertTrue(response.authorizationCodeURL.contains("code_challenge_method=S256"))
        XCTAssertTrue(response.authorizationCodeURL.contains("code_challenge="))
        XCTAssertTrue(response.authorizationCodeURL.contains(issuerURL))
    }
    
    func testPrepareCredentialRequestSuccess() async throws {
        let service = PrepareAuthorizationRequestService()
        let walletState = TestConstants.walletState
        let cscClientConfig = TestConstants.testCSCClientConfig
        let issuerURL = TestConstants.testIssuerURL
        let authorizationDetails = TestConstants.authorizationDetailsJSON
        
        let response = try await service.prepareCredentialRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            authorizationDetails: authorizationDetails,
            issuerURL: issuerURL
        )
        
        XCTAssertFalse(response.authorizationCodeURL.isEmpty)
        XCTAssertTrue(response.authorizationCodeURL.contains("response_type=code"))
        XCTAssertTrue(response.authorizationCodeURL.contains("client_id=wallet-client"))
        XCTAssertTrue(response.authorizationCodeURL.contains("scope=credential"))
        XCTAssertTrue(response.authorizationCodeURL.contains("state=\(walletState)"))
        XCTAssertTrue(response.authorizationCodeURL.contains("authorization_details="))
        XCTAssertTrue(response.authorizationCodeURL.contains(issuerURL))
    }
    
    func testPrepareCredentialRequestURLEncoding() async throws {
        let service = PrepareAuthorizationRequestService()
        let walletState = TestConstants.walletState
        let cscClientConfig = TestConstants.testCSCClientConfig
        let issuerURL = TestConstants.testIssuerURL
        let authorizationDetailsWithSpecialChars = "[{\"type\":\"credential\",\"hash\":\"test+/=\"}]"
        
        let response = try await service.prepareCredentialRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            authorizationDetails: authorizationDetailsWithSpecialChars,
            issuerURL: issuerURL
        )
        
        XCTAssertTrue(response.authorizationCodeURL.contains("authorization_details="))
        XCTAssertFalse(response.authorizationCodeURL.contains("test+/="))
    }
    
    func testPrepareServiceRequestPKCEIntegration() async throws {
        await PKCEState.shared.reset()
        
        let service = PrepareAuthorizationRequestService()
        let walletState = TestConstants.walletState
        let cscClientConfig = TestConstants.testCSCClientConfig
        let issuerURL = TestConstants.testIssuerURL
        
        let response = try await service.prepareServiceRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            issuerURL: issuerURL
        )

        XCTAssertTrue(response.authorizationCodeURL.contains("code_challenge="))
        XCTAssertTrue(response.authorizationCodeURL.contains("code_challenge_method=S256"))

        let url = URL(string: response.authorizationCodeURL)!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let codeChallenge = components.queryItems?.first(where: { $0.name == "code_challenge" })?.value
        
        XCTAssertNotNil(codeChallenge)
        XCTAssertFalse(codeChallenge!.isEmpty)
        XCTAssertEqual(codeChallenge!.count, 43)
    }
    
    func testPrepareCredentialRequestPKCEIntegration() async throws {
        await PKCEState.shared.reset()
        
        let service = PrepareAuthorizationRequestService()
        let walletState = TestConstants.walletState
        let cscClientConfig = TestConstants.testCSCClientConfig
        let issuerURL = TestConstants.testIssuerURL
        let authorizationDetails = TestConstants.authorizationDetailsJSON
        
        let response = try await service.prepareCredentialRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            authorizationDetails: authorizationDetails,
            issuerURL: issuerURL
        )

        XCTAssertTrue(response.authorizationCodeURL.contains("code_challenge="))
        XCTAssertTrue(response.authorizationCodeURL.contains("code_challenge_method=S256"))

        let url = URL(string: response.authorizationCodeURL)!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let codeChallenge = components.queryItems?.first(where: { $0.name == "code_challenge" })?.value
        
        XCTAssertNotNil(codeChallenge)
        XCTAssertFalse(codeChallenge!.isEmpty)
        XCTAssertEqual(codeChallenge!.count, 43)
    }
    
    func testPrepareServiceRequestAllQueryParameters() async throws {
        let service = PrepareAuthorizationRequestService()
        let walletState = "test-state-123"
        let cscClientConfig = CSCClientConfig(
            OAuth2Client: CSCClientConfig.OAuth2Client(clientId: "test-client-id", clientSecret: "secret"),
            authFlowRedirectionURI: "https://example.com/redirect",
            rsspId: "rssp",
            tsaUrl: nil
        )
        let issuerURL = "https://issuer.example.com"
        
        let response = try await service.prepareServiceRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            issuerURL: issuerURL
        )
        
        let url = URL(string: response.authorizationCodeURL)!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems!

        XCTAssertNotNil(queryItems.first(where: { $0.name == "response_type" && $0.value == "code" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "client_id" && $0.value == "test-client-id" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "redirect_uri" && $0.value == "https://example.com/redirect" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "scope" && $0.value == "service" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "code_challenge_method" && $0.value == "S256" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "state" && $0.value == "test-state-123" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "code_challenge" }))

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "issuer.example.com")
        XCTAssertEqual(components.path, "/oauth2/authorize")
    }
    
    func testPrepareCredentialRequestAllQueryParameters() async throws {
        let service = PrepareAuthorizationRequestService()
        let walletState = "test-state-456"
        let cscClientConfig = CSCClientConfig(
            OAuth2Client: CSCClientConfig.OAuth2Client(clientId: "cred-client", clientSecret: "secret"),
            authFlowRedirectionURI: "https://cred.example.com/callback",
            rsspId: "rssp",
            tsaUrl: nil
        )
        let issuerURL = "https://cred-issuer.example.com"
        let authorizationDetails = TestConstants.authorizationDetailsJSON
        
        let response = try await service.prepareCredentialRequest(
            walletState: walletState,
            cscClientConfig: cscClientConfig,
            authorizationDetails: authorizationDetails,
            issuerURL: issuerURL
        )
        
        let url = URL(string: response.authorizationCodeURL)!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems!

        XCTAssertNotNil(queryItems.first(where: { $0.name == "response_type" && $0.value == "code" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "client_id" && $0.value == "cred-client" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "redirect_uri" && $0.value == "https://cred.example.com/callback" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "scope" && $0.value == "credential" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "code_challenge_method" && $0.value == "S256" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "state" && $0.value == "test-state-456" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "code_challenge" }))
        XCTAssertNotNil(queryItems.first(where: { $0.name == "authorization_details" }))

        let authDetailsParam = queryItems.first(where: { $0.name == "authorization_details" })?.value
        XCTAssertNotNil(authDetailsParam)
        XCTAssertFalse(authDetailsParam!.isEmpty)
    }
} 
