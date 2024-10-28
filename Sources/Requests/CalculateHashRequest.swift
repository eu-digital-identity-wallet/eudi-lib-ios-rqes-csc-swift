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

public struct CalculateHashRequest: Codable, Sendable {
    public let documents: [Document]
    public let endEntityCertificate: String
    public let certificateChain: [String]
    public let hashAlgorithmOID: String
    
    enum CodingKeys: String, CodingKey {
        case documents
        case endEntityCertificate = "endEntityCertificate"
        case certificateChain = "certificateChain"
        case hashAlgorithmOID = "hashAlgorithmOID"
    }
    
    public struct Document: Codable, Sendable {
        public let document: String
        public let signatureFormat: String
        public let conformanceLevel: String
        public let signedEnvelopeProperty: String
        public let container: String

        enum CodingKeys: String, CodingKey {
            case document
            case signatureFormat = "signature_format"
            case conformanceLevel = "conformance_level"
            case signedEnvelopeProperty = "signed_envelope_property"
            case container
        }
        
        public init(
            document: String,
            signatureFormat: String,
            conformanceLevel: String,
            signedEnvelopeProperty: String,
            container: String
        ) {
            self.document = document
            self.signatureFormat = signatureFormat
            self.conformanceLevel = conformanceLevel
            self.signedEnvelopeProperty = signedEnvelopeProperty
            self.container = container
        }
    }
    
    public init(
        documents: [Document],
        endEntityCertificate: String,
        certificateChain: [String],
        hashAlgorithmOID: String
    ) {
        self.documents = documents
        self.endEntityCertificate = endEntityCertificate
        self.certificateChain = certificateChain
        self.hashAlgorithmOID = hashAlgorithmOID
    }
}
