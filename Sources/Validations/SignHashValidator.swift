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

struct SignHashValidator: ValidatorProtocol {

    typealias Input = SignHashRequest

    static func validate(_ input: SignHashRequest) throws {

        guard !input.credentialID.isEmpty else {
            throw SignHashError.missingCredentialID
        }

        if input.SAD == nil && input.operationMode != "credential" {
            throw SignHashError.missingSAD
        }

        guard !input.hashes.isEmpty else {
            throw SignHashError.missingHashes
        }
        
        for hash in input.hashes {
            if !isValidBase64(hash) {
                throw SignHashError.invalidBase64Hash
            }
        }

        if input.hashAlgorithmOID.isEmpty && input.signAlgo != "1.2.840.113549.1.1.1" {
            throw SignHashError.missingHashAlgorithmOID
        }

        guard !input.signAlgo.isEmpty else {
            throw SignHashError.missingSignAlgo
        }

        if let operationMode = input.operationMode {
            if !["A", "S"].contains(operationMode) {
                throw SignHashError.invalidOperationMode
            }
        }

        if input.operationMode == "A", let validityPeriod = input.validityPeriod {
            guard validityPeriod > 0 else {
                throw SignHashError.invalidValidityPeriod
            }
        }

        if input.operationMode == "A", let responseURI = input.responseURI {
            guard !responseURI.isEmpty else {
                throw SignHashError.invalidResponseURI
            }
        }
    }

    private static func isValidBase64(_ string: String) -> Bool {
        return Data(base64Encoded: string) != nil
    }
}
