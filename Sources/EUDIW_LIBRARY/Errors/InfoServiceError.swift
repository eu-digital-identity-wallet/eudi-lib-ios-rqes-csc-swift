import Foundation

public enum InfoServiceError: LocalizedError {
    case invalidURL
    case invalidResponse   
    case decodingFailed
    case invalidLanguage
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed:
            return "Failed to decode the response"
        case .invalidLanguage:
            return "The language provided is not supported. Supported languages are: en, gr, it."
        }      
    }
}
