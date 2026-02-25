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
import JOSESwift
import X509
import SwiftyJSON

// Enum defining the types of validated OpenID4VP requests
public struct ValidatedRequestData: Sendable {
  let request: Request

  public var responseMode: ResponseMode? {
    request.responseMode
  }

  public var nonce: String? {
    request.nonce
  }

  public var state: String? {
    request.state
  }
}

extension ValidatedRequestData {
  public struct Request: Sendable {
    let clientId: String
    let client: Client
    let nonce: String
    let responseUri: String?
    let responseMode: ResponseMode?
    let state: String?
    let signatureQualifier: String?
    let documentDigests: [DocumentDigest]?
    let documentLocations: [DocumentLocation]?
    let hashAlgorithmOID: String?
    let clientData: String?
      
    public init(
      clientId: String,
      client: Client,
      nonce: String,
      responseUri: String?,
      responseMode: ResponseMode?,
      state: String?,
      signatureQualifier: String?,
      documentDigests: [DocumentDigest]?,
      documentLocations: [DocumentLocation]?,
      hashAlgorithmOID: String?,
      clientData: String?
    ) {
      self.clientId = clientId
      self.client = client
      self.nonce = nonce
      self.responseUri = responseUri
      self.responseMode = responseMode
      self.state = state
      self.signatureQualifier = signatureQualifier
      self.documentDigests = documentDigests
      self.documentLocations = documentLocations
      self.hashAlgorithmOID = hashAlgorithmOID
      self.clientData = clientData
    }
  }
}

