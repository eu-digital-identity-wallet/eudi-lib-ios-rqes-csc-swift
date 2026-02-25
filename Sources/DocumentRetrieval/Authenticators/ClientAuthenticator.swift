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
@preconcurrency import Foundation
import JOSESwift
import X509
import SwiftASN1
import CryptoKit

internal actor ClientAuthenticator {
  
  let config: DocumentRetrievalConfiguration
  
  init(config: DocumentRetrievalConfiguration) {
    self.config = config
  }
  
  func authenticate(
    fetchRequest: FetchedRequest,
    requestObject: RequestObject? = nil
  ) async throws -> Client {
    switch fetchRequest {
    case .plain(let requestObject):
      guard let clientId = requestObject.clientId else {
        throw ValidationError.validationError("clientId is missing from plain request")
      }
      return try await getClient(
        clientId: clientId,
        config: config
      )
    case .jwtSecured(let clientId, let jwt):
      guard let requestObject = requestObject else {
        throw ValidationError.validationError("requestObject required for .jwtSecured")
      }
      return try await getClient(
        clientId: clientId,
        jwt: jwt,
        config: config,
        requestObject: requestObject
      )
    }
  }
  
  func getClient(
    clientId: String?,
    jwt: JWTString,
    config: DocumentRetrievalConfiguration?,
    requestObject: RequestObject
  ) async throws -> Client {
      
    guard let clientId else {
      throw ValidationError.validationError("clientId is missing")
    }
    
    guard !clientId.isEmpty else {
      throw ValidationError.validationError("clientId is missing")
    }
    
    guard
      let scheme = config?.supportedClientIdSchemes.first(
        where: { $0.scheme.rawValue == requestObject.clientIdScheme }
      ) ?? config?.supportedClientIdSchemes.first
    else {
      throw ValidationError.validationError("No supported client Id scheme")
    }
    
    switch scheme {
    case .preregistered(let clients):
      guard let client = clients[clientId] else {
        throw ValidationError.validationError("preregistered client not found")
      }
      return .preRegistered(
        clientId: clientId,
        legalName: client.legalName
      )
      
    case .x509Hash:
      guard let jws = try? JWS(compactSerialization: jwt) else {
        throw ValidationError.validationError("Unable to process JWT")
      }
      
      guard let chain: [String] = jws.header.x5c else {
        throw ValidationError.validationError("No certificate in header")
      }
      
      let certificates: [Certificate] = parseCertificates(from: chain)
      guard
        let certificate = certificates.first,
        let expectedHash = try? certificate.hashed()
      else {
        throw ValidationError.validationError("No valid certificate in chain")
      }
      
      if expectedHash != clientId {
        throw ValidationError.validationError("ClientId does not match leaf certificate's SHA-256 hash")
      }
      
      return .x509Hash(
        clientId: clientId,
        certificate: certificate
      )
      
    case .x509SanDns:
      guard let jws = try? JWS(compactSerialization: jwt) else {
        throw ValidationError.validationError("Unable to process JWT")
      }
      
      guard let chain: [String] = jws.header.x5c else {
        throw ValidationError.validationError("No certificate in header")
      }
      
      let certificates: [Certificate] = parseCertificates(from: chain)
      guard let certificate = certificates.first else {
        throw ValidationError.validationError("No certificate in chain")
      }
      
      return .x509SanDns(
        clientId: clientId,
        certificate: certificate
      )
    }
  }
  
  func getClient(
    clientId: String,
    config: DocumentRetrievalConfiguration?
  ) async throws -> Client {
    guard
      let scheme = config?.supportedClientIdSchemes.first(
        where: { $0.scheme.rawValue == clientId }
      ) ?? config?.supportedClientIdSchemes.first
    else {
      throw ValidationError.validationError("No supported client Id scheme")
    }
    
    switch scheme {
    case .preregistered(let clients):
      guard let client = clients[clientId] else {
        throw ValidationError.validationError("preregistered client not found")
      }
      return .preRegistered(
        clientId: clientId,
        legalName: client.legalName
      )
      
    default:
      throw ValidationError.validationError("Scheme \(scheme) not supported")
    }
  }
}

private extension Certificate {
  
  func hashed() throws -> String {
    var serializer = DER.Serializer()
    try serializer
      .serialize(
        self
      )
    let der = Data(
      serializer.serializedBytes
    )
    let digest = SHA256.hash(
      data: der
    )
    return Data(
      digest
    ).base64URLEncodedString
  }
}

fileprivate extension Data {
  var base64URLEncodedString: String {
    return self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
