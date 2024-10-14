import Foundation

public struct CSCCredentialsPushedAuthorizeRequest: Codable, Sendable {

    public let clientId: String
    public let responseType: String
    public let redirectUri: String
    public let scope: String
    public let codeChallenge: String
    public let codeChallengeMethod: String
    public let authorizationDetails: AuthorizationDetails?
    public let state: String?

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case responseType = "response_type"
        case redirectUri = "redirect_uri"
        case scope
        case codeChallenge = "code_challenge"
        case codeChallengeMethod = "code_challenge_method"
        case authorizationDetails = "authorization_details"
        case state
    }

    public init(
        clientId: String,
        responseType: String = "code",
        redirectUri: String,
        scope: String = "service",
        codeChallenge: String,
        codeChallengeMethod: String = "S256",
        authorizationDetails: AuthorizationDetails? = nil,
        state: String? = nil
    ) {
        self.clientId = clientId
        self.responseType = responseType
        self.redirectUri = redirectUri
        self.scope = scope
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.authorizationDetails = authorizationDetails
        self.state = state
    }
}

public struct AuthorizationDetails: Codable, Sendable {
    public let type: String
    public let credentialID: String
    public let signatureQualifier: String?
    public let documentDigests: [PushedAuthorizedDocumentDigest]
    public let hashAlgorithmOID: String

    enum CodingKeys: String, CodingKey {
        case type
        case credentialID = "credential_id"
        case signatureQualifier = "signature_qualifier"
        case documentDigests = "document_digests"
        case hashAlgorithmOID = "hash_algorithm_oid"
    }
    
    public init(
        credentialID: String,
        signatureQualifier: String? = nil,
        documentDigests: [PushedAuthorizedDocumentDigest],
        hashAlgorithmOID: String,
        type: String = "credential" 
    ) {
        self.credentialID = credentialID
        self.signatureQualifier = signatureQualifier
        self.documentDigests = documentDigests
        self.hashAlgorithmOID = hashAlgorithmOID
        self.type = type
    }
}

public struct PushedAuthorizedDocumentDigest: Codable, Sendable {
    public let hash: String
    public let label: String?

    enum CodingKeys: String, CodingKey {
        case hash
        case label
    }
    
    public init(hash: String, label: String? = nil) {
        self.hash = hash
        self.label = label
    }
}
