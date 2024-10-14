import Foundation

public enum ClientError: LocalizedError {
    case invalidRequestURL
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .invalidRequestURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server responded with an invalid response."
        }
    }
}
