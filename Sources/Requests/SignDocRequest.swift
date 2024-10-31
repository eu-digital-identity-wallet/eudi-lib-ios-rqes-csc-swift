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

public struct SignDocRequest: Codable, Sendable {

    public let credentialID: String?
    public let signatureQualifier: String?
    public let SAD: String
    
    public let documents: [Document]?

    public let operationMode: String?
    public let validityPeriod: Int?
    public let responseURI: String?
    public let clientData: String?
    public let returnValidationInfo: Bool?

    enum CodingKeys: String, CodingKey {
        case credentialID = "credential_id"
        case signatureQualifier = "signature_qualifier"
        case SAD = "SAD"
        case documents = "documents"
        case operationMode = "operation_mode"
        case validityPeriod = "validity_period"
        case responseURI = "response_uri"
        case clientData = "client_data"
        case returnValidationInfo = "return_validation_info"
    }

     init(
        credentialID: String? = nil,
        signatureQualifier: String? = nil,
        SAD: String,
        documents: [Document]? = nil,
        operationMode: String? = nil,
        validityPeriod: Int? = nil,
        responseURI: String? = nil,
        clientData: String? = nil,
        returnValidationInfo: Bool? = nil
    ) {
        self.credentialID = credentialID
        self.signatureQualifier = signatureQualifier
        self.SAD = SAD
        self.documents = documents
        self.operationMode = operationMode
        self.validityPeriod = validityPeriod
        self.responseURI = responseURI
        self.clientData = clientData
        self.returnValidationInfo = returnValidationInfo
    }
}



public struct Document: Codable, Sendable {
    public let document: String
    public let signatureFormat: String
    public let conformanceLevel: String?
    public let signAlgo: String
    public let signAlgoParams: String?
    public let signedEnvelopeProperty: String?

    enum CodingKeys: String, CodingKey {
        case document = "document"
        case signatureFormat = "signature_format"
        case conformanceLevel = "conformance_level"
        case signAlgo = "sign_algo"
        case signAlgoParams = "sign_algo_params"
        case signedEnvelopeProperty = "signed_envelope_property"
    }

    public init(document: String, signatureFormat: String, conformanceLevel: String? = nil, signAlgo: String, signAlgoParams: String? = nil, signedEnvelopeProperty: String? = nil) {
        self.document = document
        self.signatureFormat = signatureFormat
        self.conformanceLevel = conformanceLevel
        self.signAlgo = signAlgo
        self.signAlgoParams = signAlgoParams
        self.signedEnvelopeProperty = signedEnvelopeProperty
    }
}
