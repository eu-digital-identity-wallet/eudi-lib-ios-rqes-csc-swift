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
import Foundation

final actor OAuth2TokenService: OAuth2TokenServiceType {

    init() {}

    func getToken(request: AccessTokenRequest, cscClientConfig: CSCClientConfig, issuerURL: String) async throws -> AccessTokenResponse {
        
        guard let verifier = await PKCEState.shared.getVerifier() else {
            throw NSError(domain: "PKCEError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Code verifier is missing. Aborting request."])
        }
        
        let tokenRequest = OAuth2TokenRequest(
            clientId: cscClientConfig.OAuth2Client.clientId,
            redirectUri: cscClientConfig.authFlowRedirectionURI,
            grantType: "authorization_code",
            codeVerifier: verifier,
            code: request.code,
            state: request.state,
            auth: OAuth2TokenRequest.BasicAuth(
                username: cscClientConfig.OAuth2Client.clientId,
                password: cscClientConfig.OAuth2Client.clientSecret
            ),
            authorizationDetails: request.authorizationDetails ?? nil
        )
        
        let result = try await OAuth2TokenClient.makeRequest(for: tokenRequest, issuerURL: issuerURL)
        
        try await PKCEState.shared.reset()
        
        return try result.get()
    }
}
