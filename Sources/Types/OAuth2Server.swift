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

public struct OAuth2Server: Codable, Sendable {
    public let label: String?
    public let baseUri: String?
    public let issuerIdentifier: String?
    public let authType: [String]
    public let supportsRar: Bool?
  
    static let OAUTH2_CODE = "oauth2code"
    static let OAUTH2_CLIENT = "oauth2client"
  
    public init(
        label: String? = nil,
        baseUri: String? = nil,
        issuerIdentifier: String? = nil,
        authType: [String],
        supportsRar: Bool? = nil
    ) throws {
      
        let allowed = [
            Self.OAUTH2_CODE,
            Self.OAUTH2_CLIENT
        ]

        guard authType.allSatisfy({ allowed.contains($0) }) else {
            throw ValidationError.invalidAuthType
        }
      
        self.label = label
        self.baseUri = baseUri
        self.issuerIdentifier = issuerIdentifier
        self.authType = authType
        self.supportsRar = supportsRar
    }
  
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let label = try container.decodeIfPresent(String.self, forKey: .label)
        let baseUri = try container.decodeIfPresent(String.self, forKey: .baseUri)
        let issuerIdentifier = try container.decodeIfPresent(String.self, forKey: .issuerIdentifier)
        let authType = try container.decode([String].self, forKey: .authType)
        let supportsRar = try container.decodeIfPresent(Bool.self, forKey: .supportsRar)

        try self.init(
            label: label,
            baseUri: baseUri,
            issuerIdentifier: issuerIdentifier,
            authType: authType,
            supportsRar: supportsRar
        )
    }
}

