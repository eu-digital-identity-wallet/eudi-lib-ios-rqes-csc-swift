import Foundation

public struct CSCCredentialsInfoRequest: Codable, Sendable {
    public let credentialID: String
    public let certificates: String?
    public let certInfo: Bool?
    public let authInfo: Bool?
    public let lang: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case credentialID = "credential_id"
        case certificates
        case certInfo = "cert_info"
        case authInfo = "auth_info"
        case lang
        case clientData = "client_data"
    }

    public init(
        credentialID: String,
        certificates: String? = nil,
        certInfo: Bool? = nil,
        authInfo: Bool? = nil,
        lang: String? = nil,
        clientData: String? = nil
    ) {
        self.credentialID = credentialID
        self.certificates = certificates
        self.certInfo = certInfo
        self.authInfo = authInfo
        self.lang = lang
        self.clientData = clientData
    }
}
