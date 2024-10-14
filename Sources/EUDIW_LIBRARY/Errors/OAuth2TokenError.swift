import Foundation

public enum OAuth2TokenError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case missingClientId
    case missingGrantType
    case missingRedirectUri
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed:
            return "Failed to decode the response."
        case .missingClientId:
            return "The client_id is required."
        case .missingGrantType:
            return "The grant_type is required."
        case .missingRedirectUri:
            return "The redirect_uri is required for authorization_code grant type."
        }
    }
}
