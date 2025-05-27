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
    public let hashAlgorithmOID: HashAlgorithmOID
    
    enum CodingKeys: String, CodingKey {
        case documents
        case endEntityCertificate = "endEntityCertificate"
        case certificateChain = "certificateChain"
        case hashAlgorithmOID = "hashAlgorithmOID"
    }
    
    public struct Document: Codable, Sendable {
        public let documentInputPath: String
        public let documentOutputPath: String
        public let signatureFormat: SignatureFormat
        public let conformanceLevel: ConformanceLevel
        public let signedEnvelopeProperty: SignedEnvelopeProperty
        public let container: String

        enum CodingKeys: String, CodingKey {
            case documentInputPath
            case documentOutputPath
            case signatureFormat = "signature_format"
            case conformanceLevel = "conformance_level"
            case signedEnvelopeProperty = "signed_envelope_property"
            case container
        }
        
        public init(
            documentInputPath: String,
            documentOutputPath: String,
            signatureFormat: SignatureFormat,
            conformanceLevel: ConformanceLevel,
            signedEnvelopeProperty: SignedEnvelopeProperty,
            container: String
        ) {
            self.documentInputPath = documentInputPath
            self.documentOutputPath = documentOutputPath
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
        hashAlgorithmOID: HashAlgorithmOID
    ) {
        self.documents = documents
        self.endEntityCertificate = endEntityCertificate
        self.certificateChain = certificateChain
        self.hashAlgorithmOID = hashAlgorithmOID
    }
}
