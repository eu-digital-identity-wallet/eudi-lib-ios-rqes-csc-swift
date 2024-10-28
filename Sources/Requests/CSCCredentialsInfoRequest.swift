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

public struct CSCCredentialsInfoRequest: Codable, Sendable {
    public let credentialID: String
    public let credentialInfo: Bool?
    public let certificates: String?
    public let certInfo: Bool?
    public let authInfo: Bool?
    public let lang: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case credentialID = "credentialID"
        case credentialInfo = "credentialInfo"
        case certificates
        case certInfo = "certInfo"
        case authInfo = "auth_info"
        case lang
        case clientData = "client_data"
    }

    public init(
        credentialID: String,
        credentialInfo: Bool?  = nil,
        certificates: String? = nil,
        certInfo: Bool? = nil,
        authInfo: Bool? = nil,
        lang: String? = nil,
        clientData: String? = nil
    ) {
        self.credentialID = credentialID
        self.credentialInfo = credentialInfo
        self.certificates = certificates
        self.certInfo = certInfo
        self.authInfo = authInfo
        self.lang = lang
        self.clientData = clientData
    }
}
