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

public enum OAuth2AuthorizeError: LocalizedError {
    case invalidResponseType
    case missingClientId
    case missingRedirectUri
    case missingCodeChallenge
    case missingCodeChallengeMethod
    case missingCredentialID
    case missingHashesForMultipleSignatures
    case invalidAuthorizationDetails
    case invalidResponse
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .invalidResponseType:
            return "The response_type must be 'code'."
        case .missingClientId:
            return "The client_id is required."
        case .missingRedirectUri:
            return "The redirect_uri is required."
        case .missingCodeChallenge:
            return "The code_challenge is required."
        case .missingCodeChallengeMethod:
            return "The code_challenge_method is required."
        case .missingCredentialID:
            return "The credentialID is required when the scope is 'credential'."
        case .missingHashesForMultipleSignatures:
            return "Hashes are required when multiple signatures are requested."
        case .invalidAuthorizationDetails:
            return "Authorization details cannot be empty."
        case .invalidResponse:
            return "Invalid response from the server."
        case .decodingFailed:
            return "Failed to decode the response from the server."
        }
    }
}
