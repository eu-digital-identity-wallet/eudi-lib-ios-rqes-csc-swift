/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
        case credentialInfo = "credentialInfo"
        case certificates
        case certInfo = "certInfo"
        case authInfo = "auth_info"
        case onlyValid = "only_valid"
        case lang
        case clientData = "client_data"
    }

    public init(
        userID: String? = nil,
        credentialInfo: Bool? = nil,
        certificates: String? = nil,
        certInfo: Bool? = true,
        authInfo: Bool? = nil,
        onlyValid: Bool? = nil,
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
