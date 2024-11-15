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

public struct CSCCredentialsAuthorizeRequest: Codable, Sendable {

    public let credentialID: String
    public let numSignatures: Int
    public let hashes: [String]?
    public let hashAlgorithmOID: HashAlgorithmOID?
    public let authData: [AuthData]?

    public let description: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case credentialID = "credential_id"
        case numSignatures = "num_signatures"
        case hashes = "hashes"
        case hashAlgorithmOID = "hash_algorithm_oid"
        case authData = "auth_data"
        case description = "description"
        case clientData = "client_data"
    }

    public init(
        credentialID: String,
        numSignatures: Int,
        hashes: [String]? = nil,
        hashAlgorithmOID: HashAlgorithmOID? = nil,
        authData: [AuthData]? = nil,
        description: String? = nil,
        clientData: String? = nil
    ) {
        self.credentialID = credentialID
        self.numSignatures = numSignatures
        self.hashes = hashes
        self.hashAlgorithmOID = hashAlgorithmOID
        self.authData = authData
        self.description = description
        self.clientData = clientData
    }
}

public struct AuthData: Codable, Sendable {
    public let id: String
    public let value: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case value = "value"
    }
    
    public init(id: String, value: String) {
        self.id = id
        self.value = value
    }
}
