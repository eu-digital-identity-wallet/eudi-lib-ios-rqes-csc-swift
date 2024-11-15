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

public enum CSCCredentialsInfoError: LocalizedError {
    
    case invalidAuthorizationHeader
    case missingCredentialID
    case invalidCredentialID
    case invalidCertificates
    case invalidResponse
    case decodingFailed
 
    public var errorDescription: String? {
        switch self {
        case .invalidAuthorizationHeader:
            return "Malformed authorization header. The authorization header does not match the pattern 'Bearer [sessionKey]'."
        case .missingCredentialID:
            return "Missing or invalid 'credentialID' parameter. The 'credentialID' must be a valid string."
        case .invalidCredentialID:
            return "Invalid 'credentialID' parameter. The provided 'credentialID' is not valid."
        case .invalidCertificates:
            return "Invalid 'certificates' parameter. The provided 'certificates' value is not valid."
        case .invalidResponse:
            return "Invalid response from the server. The server returned a response that could not be handled."
        case .decodingFailed:
            return "Failed to decode the response. The server's response could not be parsed."
        }
    }
    
    public var statusCode: Int {
        switch self {
        case .invalidAuthorizationHeader, .missingCredentialID, .invalidCredentialID, .invalidCertificates:
            return 400
        case .invalidResponse:
            return 500
        case .decodingFailed:
            return 502
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidAuthorizationHeader:
            return "Make sure to include the correct authorization header in the format 'Bearer [sessionKey]'."
        case .missingCredentialID:
            return "Ensure the 'credentialID' parameter is included and is a valid string."
        case .invalidCredentialID:
            return "Double-check the 'credentialID' provided. It must be a valid and existing credential ID."
        case .invalidCertificates:
            return "Make sure the 'certificates' parameter is valid. Accepted values are 'none', 'single', or 'chain'."
        case .invalidResponse:
            return "Check the server's response and ensure that it's formatted correctly."
        case .decodingFailed:
            return "Ensure that the server's response matches the expected format."
        }
    }
}
