import Foundation

public struct CSCCredentialsAuthorizeRequest: Codable, Sendable {

    public let credentialID: String
    public let numSignatures: Int
    public let hashes: [String]?
    public let hashAlgorithmOID: String?
    public let authData: [AuthData]?

    public let description: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case credentialID = "credential_id"
        case numSignatures = "num_signatures"
        case hashes = "hashes"
        case hashAlgorithmOID = "hash_algorithm_oid"
        case authData = "auth_data"
        case description = "description"
        case clientData = "client_data"
    }

    public init(
        credentialID: String,
        numSignatures: Int,
        hashes: [String]? = nil,
        hashAlgorithmOID: String? = nil,
        authData: [AuthData]? = nil,
        description: String? = nil,
        clientData: String? = nil
    ) {
        self.credentialID = credentialID
        self.numSignatures = numSignatures
        self.hashes = hashes
        self.hashAlgorithmOID = hashAlgorithmOID
        self.authData = authData
        self.description = description
        self.clientData = clientData
    }
}

public struct AuthData: Codable, Sendable {
    public let id: String
    public let value: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case value = "value"
    }
    
    public init(id: String, value: String) {
        self.id = id
        self.value = value
    }
}
