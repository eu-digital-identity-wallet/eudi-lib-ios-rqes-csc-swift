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

public struct CredentialsListResponse: Codable, Sendable {
    public let credentialIDs: [String]
    public let credentialInfos: [CredentialInfo]?
    public let onlyValid:Bool?
    
    public struct CredentialInfo: Codable, Sendable {
        public let credentialID: String
        public let description: String?
        public let signatureQualifier: SignatureQualifier?
        public let key: KeyInfo
        public let cert: CertInfo
        public let auth: AuthInfo?
        public let multisign: Int?
        public let lang: String?
        public let scal: String?
    }
    
    public struct KeyInfo: Codable, Sendable {
        public let status: String
        public let algo: [String]
        public let len: Int
        public let curve: String?
    }
    
    public struct CertInfo: Codable, Sendable {
        public let status: String
        public let certificates: [String]
        public let issuerDN: String
        public let serialNumber: String
        public let subjectDN: String
        public let validFrom: String
        public let validTo: String
    }
    
    public struct AuthInfo: Codable, Sendable {
        public let mode: String?
        public let expression: String?
        public let objects: [AuthObject]?
    }
    
    public struct AuthObject: Codable, Sendable {
        public let type: String?
        public let id: String?
        public let format: String?
        public let label: String?
        public let description: String?
        public let generator: String?
    }
}
