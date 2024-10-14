import Foundation

public struct CSCCredentialsPushedAuthorizeResponse: Codable, Sendable {

    public let requestUri: String
    public let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case requestUri = "request_uri"
        case expiresIn = "expires_in"
    }

    public init(requestUri: String, expiresIn: Int) {
        self.requestUri = requestUri
        self.expiresIn = expiresIn
    }
}
