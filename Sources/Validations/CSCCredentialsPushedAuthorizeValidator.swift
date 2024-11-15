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

struct CSCCredentialsPushedAuthorizeValidator: ValidatorProtocol  {

    typealias Input = CSCCredentialsPushedAuthorizeRequest
    static func validate(_ input: CSCCredentialsPushedAuthorizeRequest) throws {

        guard !input.clientId.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingClientId
        }

        guard input.responseType == "code" else {
            throw CSCCredentialsPushedAuthorizeError.invalidResponseType
        }

        guard !input.redirectUri.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingRedirectUri
        }

        guard !input.codeChallenge.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingCodeChallenge
        }

        guard input.codeChallengeMethod == "S256" else {
            throw CSCCredentialsPushedAuthorizeError.invalidCodeChallengeMethod
        }

    }

}
