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
import SwiftyJSON

public struct DocumentDigest: Codable, Sendable {
    public let label: String
    public let hash: String
  
    public init(label: String, hash: String) {
        self.label = label
        self.hash = hash
    }

    init(json: JSON) {
        self.hash = json["hash"].stringValue
        self.label = json["label"].stringValue
    }
    
    /// Format-aware construction (for new/updated call sites)
    public init(label: String, hash: String, output format: DigestFormat) throws {
        self.label = label
        self.hash = try DigestNormalizer.normalize(hash, to: format)
    }

    public static func forAuthorization(label: String, hash: String) throws -> DocumentDigest {
        try .init(label: label, hash: hash, output: .base64URLNoPadding)
    }

    public static func forToken(label: String, hash: String) throws -> DocumentDigest {
        try .init(label: label, hash: hash, output: .base64)
    }
    
    public static func forSigning(label: String, hash: String) throws -> DocumentDigest {
        try .init(label: label, hash: hash, output: .base64)
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

public extension AuthorizationDetailsItem {

    /// Returns a new instance with the same details, but document digests normalized into the requested output format (base64 vs base64url-no-padding).
    func copy(digestFormat: DigestFormat) throws -> AuthorizationDetailsItem {
        let converted = try documentDigests.map { digest in
            try DocumentDigest(label: digest.label, hash: digest.hash, output: digestFormat)
        }

        return AuthorizationDetailsItem(
            documentDigests: converted,
            credentialID: credentialID,
            hashAlgorithmOID: hashAlgorithmOID,
            locations: locations,
            type: type
        )
    }

    /// Variant that takes hashes directly (labels preserved by index)
    func copy(hashes: [String], digestFormat: DigestFormat) throws -> AuthorizationDetailsItem {
        guard hashes.count == documentDigests.count else {
            throw NSError(
                domain: "AuthorizationDetailsItem",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "hashes.count must match documentDigests.count"]
            )
        }

        let converted: [DocumentDigest] = try zip(documentDigests, hashes).map { existing, newHash in
            try DocumentDigest(label: existing.label, hash: newHash, output: digestFormat)
        }

        return AuthorizationDetailsItem(
            documentDigests: converted,
            credentialID: credentialID,
            hashAlgorithmOID: hashAlgorithmOID,
            locations: locations,
            type: type
        )
    }

    /// Variant that takes full digests but forces a format.
    func copy(documentDigests: [DocumentDigest], digestFormat: DigestFormat) throws -> AuthorizationDetailsItem {
        let converted = try documentDigests.map { digest in
            try DocumentDigest(label: digest.label, hash: digest.hash, output: digestFormat)
        }

        return AuthorizationDetailsItem(
            documentDigests: converted,
            credentialID: credentialID,
            hashAlgorithmOID: hashAlgorithmOID,
            locations: locations,
            type: type
        )
    }
}
