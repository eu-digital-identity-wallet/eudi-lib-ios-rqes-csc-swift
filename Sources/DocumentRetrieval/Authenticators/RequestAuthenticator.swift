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

internal struct AuthenticatedRequest: Sendable {
  let client: Client
  let requestObject: RequestObject
}

internal struct JWTDecoder {
  
  static func decodeJWT(_ jwt: String) -> RequestObject? {
    // JWS compact: header.payload.signature (we only need payload)
    let parts = jwt.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count >= 2 else { return nil }
    
    guard let payloadData = String(parts[1]).base64AnyDecodedData else { return nil }
    
    do {
      let json = try JSON(data: payloadData)
      return mapJSONToRequestObject(json)
    } catch {
      return nil
    }
  }
  
  private static func mapJSONToRequestObject(_ json: JSON) -> RequestObject {
    let documentDigests = json["documentDigests"].array
    let documentLocations = json["documentLocations"].array
    
    return RequestObject(
        responseType: json["response_type"].string,
        clientId: json["client_id"].string,
        clientIdScheme: json["client_id_scheme"].string,
        responseMode: json["response_mode"].string,
        responseUri: json["response_uri"].string,
        requestUri: json["request_uri"].string,
        nonce: json["nonce"].string,
        state: json["state"].string,
        signatureQualifier: json["signatureQualifier"].string,
        documentDigests: documentDigests?.compactMap { .init(json: $0) },
        documentLocations: documentLocations?.compactMap { .init(json: $0) },
        hashAlgorithmOID:  json["hashAlgorithmOID"].string,
        clientData:  json["clientData"].string
    )
  }
}

internal actor RequestAuthenticator {
  
  let config: DocumentRetrievalConfiguration
  let clientAuthenticator: ClientAuthenticator
  
  init(config: DocumentRetrievalConfiguration, clientAuthenticator: ClientAuthenticator) {
    self.config = config
    self.clientAuthenticator = clientAuthenticator
  }
  
  func authenticate(fetchRequest: FetchedRequest) async throws -> AuthenticatedRequest {
    
    switch fetchRequest {
    case .plain(let requestObject):
      return .init(
        client: try await clientAuthenticator.authenticate(
            fetchRequest: fetchRequest
        ),
        requestObject: requestObject
      )
    case .jwtSecured(let clientId, let jwt):
      guard let requestObject = JWTDecoder.decodeJWT(jwt) else {
        throw ValidationError.invalidRequest
      }
      
      let client = try await clientAuthenticator.authenticate(
        fetchRequest: fetchRequest,
        requestObject: requestObject
      )
        
      try await verify(
        validator: AccessValidator(
          config: config,
          fetcher: Fetcher<WebKeySet>(
            session: config.session
          )
        ),
        token: jwt,
        clientId: clientId
      )
      
      return .init(client: client, requestObject: requestObject)
    }
  }
  
  func verify(
    validator: AccessValidating,
    token: JWTString,
    clientId: String?
  ) async throws {
    try await validator.validate(clientId: clientId, jwt: token)
  }
  
  func createValidatedData(
    clientId: String,
    client: Client,
    nonce: String,
    requestObject: RequestObject
  ) throws -> ValidatedRequestData {
    return .init(
        request: .init(
            clientId: clientId,
            client: client,
            nonce: nonce,
            responseUri: requestObject.responseUri,
            responseMode: try requestObject.validResponseMode(),
            state: requestObject.state,
            signatureQualifier: requestObject.signatureQualifier,
            documentDigests: requestObject.documentDigests,
            documentLocations: requestObject.documentLocations,
            hashAlgorithmOID: requestObject.hashAlgorithmOID,
            clientData: requestObject.clientData
        )
    )
  }
}

package extension String {
  
  /// Normalizes a Base64 or Base64URL string (adds padding, swaps URL-safe chars).
  var normalizedBase64: String {
    // Trim whitespace/newlines just in case
    var s = self.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Convert Base64URL alphabet to standard Base64 if present
    if s.contains("-") || s.contains("_") {
      s = s.replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    }
    
    // Pad to multiple of 4 characters
    let remainder = s.count % 4
    if remainder != 0 {
      s.append(String(repeating: "=", count: 4 - remainder))
    }
    return s
  }
  
  /// Decodes either Base64 or Base64URL.
  var base64AnyDecodedData: Data? {
    Data(base64Encoded: self.normalizedBase64, options: .ignoreUnknownCharacters)
  }
}
