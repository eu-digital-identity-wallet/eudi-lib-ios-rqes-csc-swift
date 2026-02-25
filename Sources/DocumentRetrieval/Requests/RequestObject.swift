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
@preconcurrency import SwiftyJSON

/*
 *
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request
 */
public struct RequestObject: Codable, Sendable {
    public let responseType: String?
    public let clientId: String?
    public let clientIdScheme: String?
    public let responseMode: String?
    public let responseUri: String?
    public let requestUri: String?
    public let nonce: String?
    public let state: String?
    public let signatureQualifier: String?
    public let documentDigests: [DocumentDigest]?
    public let documentLocations: [DocumentLocation]?
    public let hashAlgorithmOID: String?
    public let clientData: String?
    
  enum CodingKeys: String, CodingKey {
    case responseType = "response_type"
    case clientId = "client_id"
    case responseUri = "response_uri"
    case redirectUri = "redirect_uri"
    case clientIdScheme = "client_id_scheme"
    case nonce
    case responseMode = "response_mode"
    case state = "state"
    case requestUri = "request_uri"
    case signatureQualifier
    case documentDigests
    case documentLocations
    case hashAlgorithmOID
    case clientData
  }

  public init(
    responseType: String?,
    clientId: String?,
    clientIdScheme: String?,
    responseMode: String?,
    responseUri: String?,
    requestUri: String?,
    nonce: String?,
    state: String?,
    signatureQualifier: String?,
    documentDigests: [DocumentDigest]?,
    documentLocations: [DocumentLocation]?,
    hashAlgorithmOID: String?,
    clientData: String?
  ) {
      self.responseType = responseType
      self.clientId = clientId
      self.clientIdScheme = clientIdScheme
      self.responseMode = responseMode
      self.responseUri = responseUri
      self.requestUri = requestUri
      self.nonce = nonce
      self.state = state
      self.signatureQualifier = signatureQualifier
      self.documentDigests = documentDigests
      self.documentLocations = documentLocations
      self.hashAlgorithmOID = hashAlgorithmOID
      self.clientData = clientData
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    responseType = try? container.decode(String.self, forKey: .responseType)
    responseUri = try? container.decode(String.self, forKey: .responseUri)

    clientId = try? container.decode(String.self, forKey: .clientId)

    clientIdScheme = try? container.decode(String.self, forKey: .clientIdScheme)
    nonce = try? container.decode(String.self, forKey: .nonce)
      
    responseMode = try? container.decode(String.self, forKey: .responseMode)
    state = try? container.decode(String.self, forKey: .state)
      
    requestUri = try? container.decode(String.self, forKey: .requestUri)
      
    signatureQualifier = try? container.decode(String.self, forKey: .signatureQualifier)
    documentDigests = try? container.decode([DocumentDigest].self, forKey: .documentDigests)
    documentLocations = try? container.decode([DocumentLocation].self, forKey: .documentLocations)
    hashAlgorithmOID = try? container.decode(String.self, forKey: .hashAlgorithmOID)
    clientData = try? container.decode(String.self, forKey: .clientData)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try? container.encode(responseType, forKey: .responseType)
    try? container.encode(responseUri, forKey: .responseUri)

    try? container.encode(clientId, forKey: .clientId)
    try? container.encode(clientIdScheme, forKey: .clientIdScheme)

    try? container.encode(nonce, forKey: .nonce)
    try? container.encode(responseMode, forKey: .responseMode)
    try? container.encode(state, forKey: .state)
      
    try? container.encode(requestUri, forKey: .requestUri)
      
    try? container.encode(signatureQualifier, forKey: .signatureQualifier)
    try? container.encode(documentDigests, forKey: .documentDigests)
      
    try? container.encode(documentLocations, forKey: .documentLocations)
    try? container.encode(hashAlgorithmOID, forKey: .hashAlgorithmOID)
    try? container.encode(clientData, forKey: .clientData)
  }
}

public extension RequestObject {
  init?(from url: URL) {
    let parameters = url.queryParameters

    responseType = parameters?[CodingKeys.responseType.rawValue] as? String
    responseUri = parameters?[CodingKeys.responseUri.rawValue] as? String

    clientId = parameters?[CodingKeys.clientId.rawValue] as? String

    clientIdScheme = parameters?[CodingKeys.clientIdScheme.rawValue] as? String
    nonce = parameters?[CodingKeys.nonce.rawValue] as? String
    responseMode = parameters?[CodingKeys.responseMode.rawValue] as? String
    state = parameters?[CodingKeys.state.rawValue] as? String
      
    requestUri = parameters?[CodingKeys.requestUri.rawValue] as? String
      
    signatureQualifier = parameters?[CodingKeys.signatureQualifier.rawValue] as? String
    documentDigests = parameters?[CodingKeys.documentDigests.rawValue] as? [DocumentDigest]
    documentLocations = parameters?[CodingKeys.documentLocations.rawValue] as? [DocumentLocation]
    hashAlgorithmOID = parameters?[CodingKeys.hashAlgorithmOID.rawValue] as? String
    clientData = parameters?[CodingKeys.clientData.rawValue] as? String
  }
}

/// A utility to help with JSON parsing from query parameters.
internal struct JsonHelper {
  /// Parses a JSON array from the query parameter in the provided URL.
  /// - Parameters:
  ///   - parameter: The query parameter key.
  ///   - url: The URL containing the query parameter.
  /// - Returns: An optional array of JSON elements, or `nil` if parsing fails.
  static func jsonArray(for parameter: String, from url: URL) -> [JSON]? {
    guard
      let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
      let paramValue = queryItems.first(where: { $0.name == parameter })?.value,
      let data = paramValue.data(using: .utf8)
    else {
      return nil
    }

    let json = try? JSON(data: data)
    return json?.array
  }
}
