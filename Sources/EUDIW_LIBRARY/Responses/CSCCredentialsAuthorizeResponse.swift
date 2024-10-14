import Foundation

public struct CSCCredentialsAuthorizeResponse: Codable, Sendable {

    public let SAD: String?

    public let handle: String?

    public let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case SAD = "SAD"
        case handle = "handle"
        case expiresIn = "expires_in"
    }

    public init(SAD: String?, handle: String? = nil, expiresIn: Int? = nil) {
        self.SAD = SAD
        self.handle = handle
        self.expiresIn = expiresIn
    }

    public init(handle: String) {
        self.SAD = nil
        self.handle = handle
        self.expiresIn = nil
    }
}
