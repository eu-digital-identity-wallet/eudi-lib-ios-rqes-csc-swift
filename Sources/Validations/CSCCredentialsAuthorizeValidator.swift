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

struct CSCCredentialsAuthorizeValidator: ValidatorProtocol {
    // Define the associated type as CSCCredentialsAuthorizeRequest
    typealias Input = CSCCredentialsAuthorizeRequest

    // Static method for validation
    static func validate(_ input: CSCCredentialsAuthorizeRequest) throws {
        if input.credentialID.isEmpty {
            throw CSCCredentialsAuthorizeError.missingCredentialID
        }

        guard input.numSignatures > 0 else {
            throw CSCCredentialsAuthorizeError.invalidNumSignatures
        }

        if let hashes = input.hashes {
            guard !hashes.isEmpty else {
                throw CSCCredentialsAuthorizeError.missingHashes
            }
            for hash in hashes {
                guard !hash.isEmpty else {
                    throw CSCCredentialsAuthorizeError.invalidHashValue
                }
            }
        } else {
            throw CSCCredentialsAuthorizeError.missingHashes
        }

        guard let hashAlgorithmOID = input.hashAlgorithmOID, !hashAlgorithmOID.isEmpty else {
            throw CSCCredentialsAuthorizeError.missingHashAlgorithmOID
        }

        if let authData = input.authData {
            guard !authData.isEmpty else {
                throw CSCCredentialsAuthorizeError.missingAuthData
            }
            for auth in authData {
                guard !auth.id.isEmpty, !auth.value.isEmpty else {
                    throw CSCCredentialsAuthorizeError.invalidAuthData
                }
            }
        }
    }
}
