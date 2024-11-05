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

public struct ConformanceLevel: RawRepresentable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        guard !rawValue.isEmpty else {
            fatalError("ConformanceLevel value cannot be empty")
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

    public static let ADES_B_B = ConformanceLevel(rawValue: "Ades-B-B")
    public static let ADES_B_T = ConformanceLevel(rawValue: "Ades-B-T")
    public static let ADES_B_LT = ConformanceLevel(rawValue: "Ades-B-LT")
    public static let ADES_B_LTA = ConformanceLevel(rawValue: "Ades-B-LTA")
    public static let ADES_B = ConformanceLevel(rawValue: "Ades-B")
    public static let ADES_T = ConformanceLevel(rawValue: "Ades-T")
    public static let ADES_LT = ConformanceLevel(rawValue: "Ades-LT")
    public static let ADES_LTA = ConformanceLevel(rawValue: "Ades-LTA")
}
