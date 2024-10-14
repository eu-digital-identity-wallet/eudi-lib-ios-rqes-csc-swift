import Foundation

public struct SignHashRequest: Codable, Sendable {

    public let credentialID: String
    public let SAD: String?
    public let hashes: [String]
    public let hashAlgorithmOID: String
    public let signAlgo: String

    public let signAlgoParams: String?
    public let operationMode: String?
    public let validityPeriod: Int?
    public let responseURI: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case credentialID = "credential_id"
        case SAD = "SAD"
        case hashes
        case hashAlgorithmOID = "hash_algorithm_oid"
        case signAlgo = "sign_algo"
        case signAlgoParams = "sign_algo_params"
        case operationMode = "operation_mode"
        case validityPeriod = "validity_period"
        case responseURI = "response_uri"
        case clientData = "client_data"
    }

    public init(
        credentialID: String,
        SAD: String? = nil,
        hashes: [String],
        hashAlgorithmOID: String,
        signAlgo: String,
        signAlgoParams: String? = nil,
        operationMode: String? = nil,
        validityPeriod: Int? = nil,
        responseURI: String? = nil,
        clientData: String? = nil
    ) {
        self.credentialID = credentialID
        self.SAD = SAD
        self.hashes = hashes
        self.hashAlgorithmOID = hashAlgorithmOID
        self.signAlgo = signAlgo
        self.signAlgoParams = signAlgoParams
        self.operationMode = operationMode
        self.validityPeriod = validityPeriod
        self.responseURI = responseURI
        self.clientData = clientData
    }
}
