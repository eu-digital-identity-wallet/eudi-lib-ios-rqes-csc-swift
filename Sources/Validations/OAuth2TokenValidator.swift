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

struct OAuth2TokenValidator: ValidatorProtocol  {

    typealias Input = OAuth2TokenRequest
    static func validate(_ input: OAuth2TokenRequest) throws {
        guard !input.clientId.isEmpty else {
            throw OAuth2TokenError.missingClientId
        }
        
        guard !input.grantType.isEmpty else {
            throw OAuth2TokenError.missingGrantType
        }
        if input.grantType == "authorization_code" {
            if input.redirectUri.isEmpty {
                throw OAuth2TokenError.missingRedirectUri
            }
        }

    }
}
