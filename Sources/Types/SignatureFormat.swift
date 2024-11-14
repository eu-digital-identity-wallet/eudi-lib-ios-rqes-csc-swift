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

public struct SignatureFormat: RawRepresentable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        guard !rawValue.isEmpty else {
            fatalError("SignatureFormat value cannot be empty")
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

    public static let C = SignatureFormat(rawValue: "C")
    public static let X = SignatureFormat(rawValue: "X")
    public static let P = SignatureFormat(rawValue: "P")
    public static let J = SignatureFormat(rawValue: "J")
}
