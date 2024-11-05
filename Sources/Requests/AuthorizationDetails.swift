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

public struct DocumentDigest: Codable, Sendable {
    public let label: String
    public let hash: String
  
    public init(label: String, hash: String) {
        self.label = label
        self.hash = hash
    }
}

public struct AuthorizationDetailsItem: Codable, Sendable {
    public let documentDigests: [DocumentDigest]
    public let credentialID: String
    public let hashAlgorithmOID: HashAlgorithmOID
    public let locations: [String]
    public let type: String
  
    public init(documentDigests: [DocumentDigest], credentialID: String, hashAlgorithmOID: HashAlgorithmOID, locations: [String], type: String) {
        self.documentDigests = documentDigests
        self.credentialID = credentialID
        self.hashAlgorithmOID = hashAlgorithmOID
        self.locations = locations
        self.type = type
    }
}

public typealias AuthorizationDetails = [AuthorizationDetailsItem]
