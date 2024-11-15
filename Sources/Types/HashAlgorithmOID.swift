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

public struct HashAlgorithmOID: RawRepresentable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        guard !rawValue.isEmpty else {
            fatalError("HashAlgorithmOID value must not be blank")
        }
        self.rawValue = rawValue
    }
    
    public init(_ value: String) {
        self.init(rawValue: value)
    }

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    public var description: String {
        return rawValue
    }

    public static let SHA224 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.4")
    public static let SHA256 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
    public static let SHA385 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.2")
    public static let SHA512 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.3")
    public static let SHA3_224 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.7")
    public static let SHA3_256 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.8")
    public static let SHA3_385 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.9")
    public static let SHA3_512 = HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.10")
    public static let MD2 = HashAlgorithmOID(rawValue: "1.2.840.113549.2.2")
    public static let MD5 = HashAlgorithmOID(rawValue: "1.2.840.113549.2.5")
}
