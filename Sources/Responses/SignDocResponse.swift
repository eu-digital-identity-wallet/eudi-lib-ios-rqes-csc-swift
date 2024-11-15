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

public struct SignDocResponse: Codable, Sendable {

    public let documentWithSignature: [String]?
    public let signatureObject: [String]?
    public let responseID: String?
    public let validationInfo: ValidationInfo?

    enum CodingKeys: String, CodingKey {
        case documentWithSignature = "document_with_signature"
        case signatureObject = "signature_object"
        case responseID = "response_id"
        case validationInfo = "validation_info"
    }
    
    public init(
        documentWithSignature: [String]? = nil,
        signatureObject: [String]? = nil,
        responseID: String? = nil,
        validationInfo: ValidationInfo? = nil
    ) {
        self.documentWithSignature = documentWithSignature
        self.signatureObject = signatureObject
        self.responseID = responseID
        self.validationInfo = validationInfo
    }
}

public struct ValidationInfo: Codable, Sendable {

    public let ocsp: [String]?
    public let crl: [String]?
    public let certificates: [String]?

    enum CodingKeys: String, CodingKey {
        case ocsp = "ocsp"
        case crl = "crl"
        case certificates = "certificates"
    }

    public init(
        ocsp: [String]? = nil,
        crl: [String]? = nil,
        certificates: [String]? = nil
    ) {
        self.ocsp = ocsp
        self.crl = crl
        self.certificates = certificates
    }
}
