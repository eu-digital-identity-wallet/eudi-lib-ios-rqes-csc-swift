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

public struct CSCCredentialsPushedAuthorizeRequest: Codable, Sendable {

    public let clientId: String
    public let responseType: String
    public let redirectUri: String
    public let scope: Scope
    public let codeChallenge: String
    public let codeChallengeMethod: String
    public let authorizationDetails: String?
    public let state: String?

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case responseType = "response_type"
        case redirectUri = "redirect_uri"
        case scope
        case codeChallenge = "code_challenge"
        case codeChallengeMethod = "code_challenge_method"
        case authorizationDetails = "authorization_details"
        case state
    }

    public init(
        clientId: String,
        responseType: String = "code",
        redirectUri: String,
        scope: Scope = Scope.SERVICE,
        codeChallenge: String,
        codeChallengeMethod: String = "S256",
        authorizationDetails: String? = nil,
        state: String? = nil
    ) {
        self.clientId = clientId
        self.responseType = responseType
        self.redirectUri = redirectUri
        self.scope = scope
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.authorizationDetails = authorizationDetails
        self.state = state
    }
}
