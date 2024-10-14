import Foundation

public struct CSCCredentialsListResponse: Codable, Sendable {
    public let credentialIDs: [String]
    public let credentialInfos: [CredentialInfo]?
    
    public struct CredentialInfo: Codable, Sendable  {
        public let credentialID: String
        public let description: String?
        public let signatureQualifier: String?
        public let key: KeyInfo
        public let cert: CertInfo
        public let auth: AuthInfo?
        public let multisign: Int?
        public let lang: String?
    }
    
    public struct KeyInfo: Codable, Sendable  {
        public let status: String
        public let algo: [String]
        public let len: Int
        public let curve: String?
    }
    
    public struct CertInfo: Codable, Sendable  {
        public let status: String
        public let certificates: [String]
        public let issuerDN: String
        public let serialNumber: String
        public let subjectDN: String
        public let validFrom: String
        public let validTo: String
    }
    
    public struct AuthInfo: Codable, Sendable  {
        public let mode: String
        public let expression: String?
        public let objects: [AuthObject]
    }
    
    public struct AuthObject: Codable, Sendable  {
        public let type: String
        public let id: String
        public let format: String
        public let label: String
        public let description: String
        public let generator: String?
    }
}
