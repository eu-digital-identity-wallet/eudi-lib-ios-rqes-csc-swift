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

public struct InfoServiceResponse: Codable, Sendable {
    public let specs: String
    public let name: String
    public let logo: String
    public let region: String
    public let lang: String
    public let description: String
    public let authType: [String]
    public let oauth2: String
    public let oauth2Issuer: String?
    public let methods: [RSSPMethod]
    public let validationInfo: Bool?
    public let signAlgorithms: SignAlgorithms
    public let signature_formats: SignatureFormats
    public let conformanceLevels: [String]
    public let oauth2Servers: [OAuth2Server]?
    public let supportsRar: Bool?
    public let supportedHashTypes: [String]
    public let documentTypes: [String]?
  
    enum CodingKeys: String, CodingKey {
        case specs
        case name
        case logo
        case region
        case lang
        case description
        case authType
        case oauth2
        case oauth2Issuer
        case methods
        case validationInfo
        case signAlgorithms
        case signature_formats
        case conformanceLevels = "conformance_levels"
        case oauth2Servers
        case supportsRar
        case supportedHashTypes
        case documentTypes
    }

    public var oauth2BaseURL: String? {

        guard let validatedServer = validatedOAuth2Server() else {
            return oauth2
        }

        return validatedServer.baseUri ?? oauth2
    }

    private func validatedOAuth2Server() -> OAuth2Server? {

        guard let servers = oauth2Servers else {
            return nil
        }

        do {
            try validateOAuthConfiguration(servers: servers)

            // Placeholder selection logic
            return servers.first

        } catch {
            return nil
        }
    }

    private func validateOAuthConfiguration(servers: [OAuth2Server]) throws {

        // supportsRar SHALL NOT be present if oauth2Servers is present
        if supportsRar != nil {
            throw MetadataError.supportsRarMustNotBePresentWhenOAuth2ServersPresent
        }

        // Exactly one of oauth2, oauth2Issuer, oauth2Servers SHALL be present
        let presentCount = [
            oauth2Issuer != nil,
            oauth2Servers != nil
        ]
        .filter { $0 }
        .count

        guard presentCount == 1 else {
            throw MetadataError.exactlyOneOAuthSourceMustBePresent
        }

        // oauth2Servers SHALL only be present if authType contains oauth2code or oauth2client
        let allowedOAuthTypes = Set([
            OAuth2Server.OAUTH2_CODE,
            OAuth2Server.OAUTH2_CLIENT
        ])

        let metadataOAuthTypes = Set(
            authType.filter { allowedOAuthTypes.contains($0) }
        )

        guard !metadataOAuthTypes.isEmpty else {
            throw MetadataError.oauth2ServersRequireOAuthAuthType
        }

        // oauth2Servers SHALL collectively satisfy all oauth2-related authTypes declared in metadata.authType
        let serversUnionAuthTypes = Set(
            servers.flatMap(\.authType)
        )

        guard metadataOAuthTypes.isSubset(of: serversUnionAuthTypes) else {
            throw MetadataError.oauth2ServersMustSatisfyMetadataAuthTypes
        }
    }

    public enum MetadataError: Error {
        case supportsRarMustNotBePresentWhenOAuth2ServersPresent
        case exactlyOneOAuthSourceMustBePresent
        case oauth2ServersRequireOAuthAuthType
        case oauth2ServersMustSatisfyMetadataAuthTypes
    }
}

public struct SignAlgorithms: Codable, Sendable {
    public let algos: [String]
    public let algoParams: [String]
}

public struct SignatureFormats: Codable, Sendable{
    public let formats: [String]
    public let envelope_properties: [[String]]
    public let allowMix: Bool?
  
    public init(formats: [String], envelope_properties: [[String]], allowMix: Bool? = false) {
        self.formats = formats
        self.envelope_properties = envelope_properties
        self.allowMix = allowMix
    }
}

public enum RSSPMethod: String, Codable, Sendable {
    case info = "info"
    case authorize = "oauth2/authorize"
    case token = "oauth2/token"
    case authLogin = "auth/login"
    case authRevoke = "auth/revoke"
    case credentialsList = "credentials/list"
    case credentialsInfo = "credentials/info"
    case credentialsAuthorize = "credentials/authorize"
    case credentialsAuthorizeCheck = "credentials/authorize/check"
    case credentialsGetChallenge = "credentials/getChallenge"
    case credentialsSendOTP = "credentials/sendOTP"
    case credentialsExtendTransaction = "credentials/extendTransaction"
    case credentialsCreate = "credentials/create"
    case credentialsDelete = "credentials/delete"
    case signaturesSignHash = "signatures/signHash"
    case signaturesSignDoc = "signatures/signDoc"
    case signaturesSignPolling = "signatures/signPolling"
    case signaturesTimestamp = "signatures/timestamp"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        guard let method = RSSPMethod(rawValue: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid RSSPMethod: \(value)"
            )
        }

        self = method
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
