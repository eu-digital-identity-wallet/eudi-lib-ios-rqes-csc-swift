import Foundation

public enum CSCCredentialsPushedAuthorizeError: LocalizedError {
    case missingClientId
    case invalidResponseType
    case missingRedirectUri
    case missingCodeChallenge
    case invalidCodeChallengeMethod
    case invalidAuthorizationType
    case missingCredentialID
    case missingDocumentDigests
    case missingHashAlgorithmOID
    case missingHash
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .missingClientId:
            return "The 'client_id' parameter is missing or empty."
        case .invalidResponseType:
            return "The 'response_type' parameter must be 'code'."
        case .missingRedirectUri:
            return "The 'redirect_uri' parameter is missing or empty."
        case .missingCodeChallenge:
            return "The 'code_challenge' parameter is missing or empty."
        case .invalidCodeChallengeMethod:
            return "The 'code_challenge_method' must be 'S256'."
        case .invalidAuthorizationType:
            return "The authorization 'type' must be 'credential'."
        case .missingCredentialID:
            return "The 'credential_id' is missing or empty in the authorization details."
        case .missingDocumentDigests:
            return "The 'document_digests' array is missing or empty."
        case .missingHashAlgorithmOID:
            return "The 'hash_algorithm_oid' is missing or empty in the authorization details."
        case .missingHash:
            return "The 'hash' in the document digest is missing or empty."
        case .invalidResponse:
            return "The server responded with an invalid response."
        }
    }
}
