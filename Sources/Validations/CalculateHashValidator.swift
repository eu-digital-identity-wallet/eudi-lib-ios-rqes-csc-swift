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

struct CalculateHashValidator {
    
    static func validate(request: CalculateHashRequest) throws {

        guard !request.documents.isEmpty else {
            throw CalculateHashError.missingDocuments
        }

        for document in request.documents {
            guard !document.document.isEmpty else {
                throw CalculateHashError.invalidDocument
            }
        }

        guard !request.endEntityCertificate.isEmpty else {
            throw CalculateHashError.missingEndEntityCertificate
        }

        guard !request.certificateChain.isEmpty else {
            throw CalculateHashError.missingCertificateChain
        }

        guard !request.hashAlgorithmOID.isEmpty else {
            throw CalculateHashError.missingHashAlgorithmID
        }
    }
}
