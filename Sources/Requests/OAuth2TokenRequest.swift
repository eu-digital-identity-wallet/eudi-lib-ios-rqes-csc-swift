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

public struct OAuth2TokenRequest: Codable, Sendable {
    public let clientId: String
    public let redirectUri: String
    public let grantType: String
    public let codeVerifier: String
    public let code: String
    public let state: String
    public let auth: BasicAuth?
    public let authorizationDetails: String?

    public struct BasicAuth: Codable, Sendable {
        public let username: String
        public let password: String
        
        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case redirectUri = "redirect_uri"
        case grantType = "grant_type"
        case codeVerifier = "code_verifier"
        case code
        case state
        case auth
        case authorizationDetails = "authorization_details"
    }

    public init(
        clientId: String,
        redirectUri: String,
        grantType: String,
        codeVerifier: String,
        code: String,
        state: String,
        auth: BasicAuth? = nil,
        authorizationDetails: String? = nil
    ) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.grantType = grantType
        self.codeVerifier = codeVerifier
        self.code = code
        self.state = state
        self.auth = auth
        self.authorizationDetails = authorizationDetails
    }
    
    public func toFormBody() -> Data {
        let formItems = [
            "client_id": clientId,
            "redirect_uri": redirectUri,
            "grant_type": grantType,
            "code_verifier": codeVerifier,
            "code": code,
            "state": state
        ].compactMapValues { $0 }

        return formItems.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8) ?? Data()
    }
}
