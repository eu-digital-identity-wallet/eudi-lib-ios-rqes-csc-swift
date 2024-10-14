import Foundation

public struct CSCCredentialsListRequest: Codable, Sendable {
    public let userID: String?
    public let credentialInfo: Bool?
    public let certificates: String?
    public let certInfo: Bool?
    public let authInfo: Bool?
    public let onlyValid: Bool?
    public let lang: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case credentialInfo = "credential_info"
        case certificates
        case certInfo = "cert_info"
        case authInfo = "auth_info"
        case onlyValid = "only_valid"
        case lang
        case clientData = "client_data"
    }

    public init(
        userID: String? = nil,
        credentialInfo: Bool? = false,
        certificates: String? = "single",
        certInfo: Bool? = false,
        authInfo: Bool? = false,
        onlyValid: Bool? = false,
        lang: String? = nil,
        clientData: String? = nil
    ) {
        self.userID = userID
        self.credentialInfo = credentialInfo
        self.certificates = certificates
        self.certInfo = certInfo
        self.authInfo = authInfo
        self.onlyValid = onlyValid
        self.lang = lang
        self.clientData = clientData
    }

    public func toFormBody() -> Data {
        let formItems = [
            "user_id": userID,
            "credential_info": credentialInfo.map { $0 ? "true" : "false" },
            "certificates": certificates,
            "cert_info": certInfo.map { $0 ? "true" : "false" },
            "auth_info": authInfo.map { $0 ? "true" : "false" },
            "only_valid": onlyValid.map { $0 ? "true" : "false" },
            "lang": lang,
            "client_data": clientData
        ].compactMapValues { $0 }

        return formItems.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8) ?? Data()
    }
}
