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

public enum CSCCredentialsAuthorizeError: LocalizedError {
    case missingCredentialID
    case invalidNumSignatures
    case missingHashes
    case invalidHashValue
    case missingHashAlgorithmOID
    case missingAuthData
    case invalidAuthData
    case invalidRequestURL
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .missingCredentialID:
            return "Missing or invalid 'credentialID' parameter."
        case .invalidNumSignatures:
            return "Invalid or missing 'numSignatures' parameter. It must be greater than 0."
        case .missingHashes:
            return "Missing or empty 'hashes' array."
        case .invalidHashValue:
            return "Invalid hash value in 'hashes' array."
        case .missingHashAlgorithmOID:
            return "Missing or invalid 'hashAlgorithmOID' parameter."
        case .missingAuthData:
            return "Missing or empty 'authData' array."
        case .invalidAuthData:
            return "Invalid authentication data in 'authData'. Both 'id' and 'value' must be non-empty."
        case .invalidRequestURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server responded with an invalid response."
        }
    }
}
