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

struct OAuth2AuthorizeValidator: ValidatorProtocol  {
    typealias Input = OAuth2AuthorizeRequest
    private static let requiredResponseType = "code"

    static func validate(_ input: OAuth2AuthorizeRequest) throws {
        guard input.responseType == requiredResponseType else {
            throw OAuth2AuthorizeError.invalidResponseType
        }

        guard !input.clientId.isEmpty else {
            throw OAuth2AuthorizeError.missingClientId
        }

        guard !input.redirectUri.isEmpty else {
            throw OAuth2AuthorizeError.missingRedirectUri
        }

        guard !input.codeChallenge.isEmpty else {
            throw OAuth2AuthorizeError.missingCodeChallenge
        }
        guard !input.codeChallengeMethod.isEmpty else {
            throw OAuth2AuthorizeError.missingCodeChallengeMethod
        }

        try validateConditionalFields(for: input)
    }

    private static func validateConditionalFields(for request: OAuth2AuthorizeRequest) throws {
        if request.scope == "credential" {
            guard let credentialID = request.credentialID, !credentialID.isEmpty else {
                throw OAuth2AuthorizeError.missingCredentialID
            }
            
            if request.numSignatures != nil && request.hashes == nil {
                throw OAuth2AuthorizeError.missingHashesForMultipleSignatures
            }
        }
        
        if let authorizationDetails = request.authorizationDetails, authorizationDetails.isEmpty {
            throw OAuth2AuthorizeError.invalidAuthorizationDetails
        }
    }
}
