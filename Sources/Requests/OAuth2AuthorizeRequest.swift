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

public struct OAuth2AuthorizeRequest: Codable, Sendable {
    public let responseType: String
    public let clientId: String
    public let redirectUri: String
    public let scope: String
    public let codeChallenge: String
    public let codeChallengeMethod: String
    public let state: String?
    public let credentialID: String?
    public let signatureQualifier: String?
    public let numSignatures: Int?
    public let hashes: String?
    public let hashAlgorithmOID: String?
    public let authorizationDetails: String?
    public let requestUri: String?

    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case clientId = "client_id"
        case redirectUri = "redirect_uri"
        case scope
        case codeChallenge = "code_challenge"
        case codeChallengeMethod = "code_challenge_method"
        case state
        case credentialID = "credential_id"
        case signatureQualifier = "signature_qualifier"
        case numSignatures = "num_signatures"
        case hashes
        case hashAlgorithmOID = "hash_algorithm_oid"
        case authorizationDetails = "authorization_details"
        case requestUri = "request_uri"
    }

    public init(
        responseType: String,
        clientId: String,
        redirectUri: String,
        scope: String,
        codeChallenge: String,
        codeChallengeMethod: String,
        state: String? = nil,
        credentialID: String? = nil,
        signatureQualifier: String? = nil,
        numSignatures: Int? = nil,
        hashes: String? = nil,
        hashAlgorithmOID: String? = nil,
        authorizationDetails: String? = nil,
        requestUri: String? = nil
    ) {
        self.responseType = responseType
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.state = state
        self.credentialID = credentialID
        self.signatureQualifier = signatureQualifier
        self.numSignatures = numSignatures
        self.hashes = hashes
        self.hashAlgorithmOID = hashAlgorithmOID
        self.authorizationDetails = authorizationDetails
        self.requestUri = requestUri
    }

    public func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod)
        ]
        
        if let state = state { items.append(URLQueryItem(name: "state", value: state)) }
        if let credentialID = credentialID { items.append(URLQueryItem(name: "credential_id", value: credentialID)) }
        if let signatureQualifier = signatureQualifier { items.append(URLQueryItem(name: "signature_qualifier", value: signatureQualifier)) }
        if let numSignatures = numSignatures { items.append(URLQueryItem(name: "num_signatures", value: "\(numSignatures)")) }
        if let hashes = hashes { items.append(URLQueryItem(name: "hashes", value: hashes)) }
        if let hashAlgorithmOID = hashAlgorithmOID { items.append(URLQueryItem(name: "hash_algorithm_oid", value: hashAlgorithmOID)) }
        if let authorizationDetails = authorizationDetails { items.append(URLQueryItem(name: "authorization_details", value: authorizationDetails)) }
        if let requestUri = requestUri { items.append(URLQueryItem(name: "request_uri", value: requestUri)) }
        
        return items
    }
}
