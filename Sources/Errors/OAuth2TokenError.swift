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

public enum OAuth2TokenError: LocalizedError {
    case missingClientId
    case missingGrantType
    case missingRedirectUri
    
    public var errorDescription: String? {
        switch self {
        case .missingClientId:
            return "The client_id is required."
        case .missingGrantType:
            return "The grant_type is required."
        case .missingRedirectUri:
            return "The redirect_uri is required for authorization_code grant type."
        }
    }
}
