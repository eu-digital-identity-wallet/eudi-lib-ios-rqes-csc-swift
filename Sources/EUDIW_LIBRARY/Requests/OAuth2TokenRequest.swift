import Foundation

public struct OAuth2TokenRequest: Codable, Sendable {
    public let grantType: String
    public let clientId: String
    public let clientSecret: String?
    public let code: String?
    public let refreshToken: String?
    public let redirectUri: String?
    public let clientAssertion: String?
    public let clientAssertionType: String?
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case refreshToken = "refresh_token"
        case redirectUri = "redirect_uri"
        case clientAssertion = "client_assertion"
        case clientAssertionType = "client_assertion_type"
    }

    public init(
        grantType: String,
        clientId: String,
        clientSecret: String? = nil,
        code: String? = nil,
        refreshToken: String? = nil,
        redirectUri: String? = nil,
        clientAssertion: String? = nil,
        clientAssertionType: String? = nil
    ) {
        self.grantType = grantType
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.code = code
        self.refreshToken = refreshToken
        self.redirectUri = redirectUri
        self.clientAssertion = clientAssertion
        self.clientAssertionType = clientAssertionType
    }
    
    public func toFormBody() -> Data {
        let formItems = [
            "grant_type": grantType,
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "refresh_token": refreshToken,
            "redirect_uri": redirectUri,
            "client_assertion": clientAssertion,
            "client_assertion_type": clientAssertionType
        ].compactMapValues { $0 }

        return formItems.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8) ?? Data()
    }
}
