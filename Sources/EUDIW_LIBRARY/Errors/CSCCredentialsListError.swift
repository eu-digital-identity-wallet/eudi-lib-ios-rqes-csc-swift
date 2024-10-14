import Foundation

public enum CSCCredentialsListError: LocalizedError {
    case invalidClientID
    case invalidResponse
    case noData
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .invalidClientID:
            return "The client ID provided is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .noData:
            return "No data was received from the server."
        case .decodingFailed:
            return "Failed to decode the response."
        }
    }
}
