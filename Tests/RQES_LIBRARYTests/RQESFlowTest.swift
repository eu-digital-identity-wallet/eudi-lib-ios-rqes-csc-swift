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
@testable import RQES_LIBRARY

final class RQESFlowTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeInfoService() async throws {
        let request = InfoServiceRequest(lang: "en-US")

        do {
            
            // STEP 1: Initialize an instance of RQES to access library services
            // This initializes the RQES object for invoking various service methods
            let rqes = await RQES()
            
            // STEP 2: Retrieve service information using the InfoService
            let response = try await rqes.getInfo(request: request)
            JSONUtils.prettyPrintResponseAsJSON(response, message: "InfoService Response:")
            
            // STEP 3: Create a login request with test credentials
            let loginRequest = LoginRequest(username: "8PfCAQzTmON+FHDvH4GW/g+JUtg5eVTgtqMKZFdB/+c=;FirstName;TesterUser",
                                            password: "5adUg@35Lk_Wrm3")
            
            // STEP 4: Perform the login operation and capture the response
            let loginResponse = try await rqes.login(request: loginRequest)
            JSONUtils.prettyPrintResponseAsJSON(loginResponse, message: "Login Response:")
            
            // STEP 5: Set up an authorization request using OAuth2AuthorizeRequest with required parameters
            let authorizeRequest = OAuth2AuthorizeRequest(
                responseType: "code",
                clientId: "wallet-client",
                redirectUri: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
                scope: "service",
                codeChallenge: "V4n5D1_bu7BPMXWsTulFVkC4ASFmeS7lHXSqIf-vUwI",
                codeChallengeMethod: "S256",
                state: "erv8utb5uie",
                credentialID: nil,
                signatureQualifier: nil,
                numSignatures: nil,
                hashes: nil,
                hashAlgorithmOID: nil,
                authorizationDetails: nil,
                requestUri: nil,
                cookie: loginResponse.cookie!
            )
            
            let authorizeResponse = try await rqes.getAuthorizeUrl(request: authorizeRequest)
            JSONUtils.prettyPrintResponseAsJSON(authorizeResponse, message: "Authorize Response:")
            
            // STEP 6: Request an OAuth2 Token using the authorization code
            
            let tokenRequest = OAuth2TokenRequest(
                clientId: "wallet-client-tester",
                redirectUri: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
                grantType: "authorization_code",
                codeVerifier: "z34oHaauNSc13ScLRDmbQrJ5bIR9IDzRCWZTRRAPtlV",
                code: authorizeResponse.code,
                state:"erv8utb5uie",
                auth: OAuth2TokenRequest.BasicAuth(
                    username: "wallet-client",
                    password: "somesecret2"
                )
            )
            
            let tokenResponse = try await rqes.getOAuth2Token(request: tokenRequest)
            JSONUtils.prettyPrintResponseAsJSON(tokenResponse, message: "Token Response:")  
            
            // STEP 7: Request the list of credentials using the access token
            
            let credentialListRequest = CSCCredentialsListRequest(
                credentialInfo: true,
                certificates: "chain",
                certInfo: true
            )
            
            let credentialListResponse = try await rqes.getCredentialsList(request: credentialListRequest, accessToken: tokenResponse.accessToken)
            JSONUtils.prettyPrintResponseAsJSON(credentialListResponse, message: "Credential List Response:")
            
            // STEP 8: Request the list of credentials using the access token
            
            let credentialInfoRequest = CSCCredentialsInfoRequest(
                credentialID: credentialListResponse.credentialIDs[0],
                credentialInfo: true,
                certificates: "chain",
                certInfo: true
            )
            
            let credentialInfoResponse = try await rqes.getCredentialsInfo(request: credentialInfoRequest, accessToken: tokenResponse.accessToken)
            JSONUtils.prettyPrintResponseAsJSON(credentialInfoResponse, message: "Credential Info Response:")
            
            // STEP 9: Request the list of credentials using the access token
            
            let calculateHashRequest = CalculateHashRequest(
                documents: [
                    CalculateHashRequest.Document(
                        document: encodedPdfExample,
                        signatureFormat: "P",
                        conformanceLevel: "Ades-B-B",
                        signedEnvelopeProperty: "ENVELOPED",
                        container: "No"
                    )
                ],
                endEntityCertificate: (credentialInfoResponse.cert?.certificates?[0])!,
                certificateChain: [(credentialInfoResponse.cert?.certificates?[1])!],
                hashAlgorithmOID: "1.2.840.113549.1.1.11"
            )
            
            let calculateHashResponse = try await rqes.calculateHash(request: calculateHashRequest, accessToken: tokenResponse.accessToken)
            JSONUtils.prettyPrintResponseAsJSON(calculateHashResponse, message: "Calculate Hash Response:")

            
            
            
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
}
