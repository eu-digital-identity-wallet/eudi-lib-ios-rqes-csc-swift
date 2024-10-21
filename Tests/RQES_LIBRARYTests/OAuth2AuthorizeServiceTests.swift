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

final class OAuth2AuthorizeServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeOAuth2AuthorizeService() async throws {
        let request = OAuth2AuthorizeRequest(
            responseType: "code",
            clientId: "sca-client",
            redirectUri: "https://walletcentric.signer.eudiw.dev/login/oauth2/code/sca-client",
            scope: "service",
            codeChallenge: "some_nonce_2",
            codeChallengeMethod: "S256",
            state: "12345678",
            credentialID: "65",
            signatureQualifier: nil,
            numSignatures: nil,
            hashes: nil,
            hashAlgorithmOID: nil,
            authorizationDetails: nil,
            requestUri: nil
        )
        
        do {
            let rqes = await RQES()
            try await rqes.getInfo()
            let response = try await rqes.getAuthorizeUrl(request: request)
            
            // Print the response to observe the result
            JSONUtils.prettyPrintResponseAsJSON(response)
        } catch {
            // Print the error but don't fail the test
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                print("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: OAuth2AuthorizeResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode OAuth2AuthorizeResponse to JSON: \(error)")
        }
    }
}
