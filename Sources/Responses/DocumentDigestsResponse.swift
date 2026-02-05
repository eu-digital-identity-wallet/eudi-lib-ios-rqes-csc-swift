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

public struct DocumentDigests: Codable, Sendable {
    public let hashes: [String]
    
    enum CodingKeys: String, CodingKey {
        case hashes
    }
    
    public init(hashes: [String]) {
        self.hashes = hashes
    }

    public init(digests: [String], output format: DigestFormat) throws {
        self.hashes = try digests.map { try DigestNormalizer.normalize($0, to: format) }
    }

    public static func forAuthorization(digests: [String]) throws -> DocumentDigests {
        try .init(digests: digests, output: .base64URLNoPadding)
    }

    public static func forToken(digests: [String]) throws -> DocumentDigests {
        try .init(digests: digests, output: .base64)
    }
}

public enum DigestFormat: Sendable {
    case base64
    case base64URLNoPadding
}

public enum DigestError: Error, LocalizedError, Sendable {
    case blank
    case invalid

    public var errorDescription: String? {
        switch self {
        case .blank:
            return "Digest must not be blank"
        case .invalid:
            return "Digest must be a valid Base64 or Base64URL encoded string"
        }
    }
}

internal enum DigestNormalizer {
    static func normalize(_ input: String, to format: DigestFormat) throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DigestError.blank }

        // Accept percent-encoded input too
        let decoded = trimmed.removingPercentEncoding ?? trimmed

        // Try standard Base64 first
        if let data = Data(base64Encoded: decoded) {
            return encode(data, as: format)
        }

        // Try Base64URL (no padding, -/_)
        if let data = Data(base64URLEncoded: decoded) {
            return encode(data, as: format)
        }

        throw DigestError.invalid
    }

    static func encode(_ data: Data, as format: DigestFormat) -> String {
        switch format {
        case .base64:
            return data.base64EncodedString()
        case .base64URLNoPadding:
            return data.base64URLEncodedStringNoPadding()
        }
    }
}

private extension Data {
    func base64URLEncodedStringNoPadding() -> String {
        self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    init?(base64URLEncoded s: String) {
        var base64 = s
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let pad = (4 - (base64.count % 4)) % 4
        if pad > 0 { base64 += String(repeating: "=", count: pad) }

        self.init(base64Encoded: base64)
    }
}
