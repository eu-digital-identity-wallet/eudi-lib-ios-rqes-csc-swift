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

public struct SignatureQualifier: RawRepresentable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
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

    public static let EU_EIDAS_QES = SignatureQualifier(rawValue: "eu_eidas_qes")
    public static let EU_EIDAS_AES = SignatureQualifier(rawValue: "eu_eidas_aes")
    public static let EU_EIDAS_AESQC = SignatureQualifier(rawValue: "eu_eidas_aesqc")
    public static let EU_EIDAS_QESEAL = SignatureQualifier(rawValue: "eu_eidas_qeseal")
    public static let EU_EIDAS_AESEAL = SignatureQualifier(rawValue: "eu_eidas_aeseal")
    public static let EU_EIDAS_AESEALQC = SignatureQualifier(rawValue: "eu_eidas_aesealqc")
    public static let ZA_ECTA_AES = SignatureQualifier(rawValue: "za_ecta_aes")
    public static let ZA_ECTA_OES = SignatureQualifier(rawValue: "za_ecta_oes")
}
