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

struct SignDocValidator: ValidatorProtocol  {

    typealias Input = SignDocRequest

    static func validate(_ input: SignDocRequest) throws {

        if input.credentialID == nil && input.signatureQualifier == nil {
            throw SignDocError.missingCredentialIDAndSignatureQualifier
        }

        if input.documentDigests == nil && input.documents == nil {
            throw SignDocError.missingDocumentDigestsAndDocuments
        }

        if let documentDigests = input.documentDigests {
            for digest in documentDigests {
                if digest.hashes.isEmpty {
                    throw SignDocError.emptyHashes
                }
            }
        }

        if let documents = input.documents {
            for document in documents {
                if document.document.isEmpty {
                    throw SignDocError.missingDocument
                }
            }
        }

        if let operationMode = input.operationMode {
            if operationMode != "A" {
                throw SignDocError.invalidValidityPeriod
            }
        }

        if let returnValidationInfo = input.returnValidationInfo, returnValidationInfo {
            guard let document = input.documents?.first else { return }
            if document.signatureFormat != "P" {
                throw SignDocError.invalidReturnValidationInfo
            }
        }
    }
}
