import Foundation

public struct SignDocRequest: Codable, Sendable {

    public let credentialID: String?
    public let signatureQualifier: String?
    public let SAD: String
    public let documentDigests: [DocumentDigest]?
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
        case documentDigests = "document_digests"
        case documents = "documents"
        case operationMode = "operation_mode"
        case validityPeriod = "validity_period"
        case responseURI = "response_uri"
        case clientData = "client_data"
        case returnValidationInfo = "return_validation_info"
    }

    public init(
        credentialID: String? = nil,
        signatureQualifier: String? = nil,
        SAD: String,
        documentDigests: [DocumentDigest]? = nil,
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
        self.documentDigests = documentDigests
        self.documents = documents
        self.operationMode = operationMode
        self.validityPeriod = validityPeriod
        self.responseURI = responseURI
        self.clientData = clientData
        self.returnValidationInfo = returnValidationInfo
    }
}

public struct DocumentDigest: Codable, Sendable {
    public let hashes: [String]
    public let hashAlgorithmOID: String
    public let signatureFormat: String
    public let conformanceLevel: String?
    public let signAlgo: String
    public let signAlgoParams: String?

    enum CodingKeys: String, CodingKey {
        case hashes = "hashes"
        case hashAlgorithmOID = "hash_algorithm_oid"
        case signatureFormat = "signature_format"
        case conformanceLevel = "conformance_level"
        case signAlgo = "sign_algo"
        case signAlgoParams = "sign_algo_params"
    }

    public init(hashes: [String], hashAlgorithmOID: String, signatureFormat: String, conformanceLevel: String? = nil, signAlgo: String, signAlgoParams: String? = nil) {
        self.hashes = hashes
        self.hashAlgorithmOID = hashAlgorithmOID
        self.signatureFormat = signatureFormat
        self.conformanceLevel = conformanceLevel
        self.signAlgo = signAlgo
        self.signAlgoParams = signAlgoParams
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
