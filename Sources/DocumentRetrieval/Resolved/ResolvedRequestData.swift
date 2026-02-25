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

public struct ResolvedRequestData: Sendable {
    public let client: Client
    public let nonce: String
    public let responseUri: URL?
    public let responseMode: ResponseMode?
    public let state: String?
    public let signatureQualifier: String?
    public let documentDigests: [DocumentDigest]?
    public let documentLocations: [DocumentLocation]?
    public let hashAlgorithmOID: String?
    public let clientData: String?
    
    public init(
      client: Client,
      nonce: String,
      responseMode: ResponseMode?,
      responseUri: URL?,
      state: String?,
      signatureQualifier: String?,
      documentDigests: [DocumentDigest]?,
      documentLocations: [DocumentLocation]?,
      hashAlgorithmOID: String?,
      clientData: String?
    ) {
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

public extension ResolvedRequestData {
  
  /// Initializes a `ResolvedRequestData` instance with the provided parameters.
  init(
    config: DocumentRetrievalConfiguration,
    validatedAuthorizationRequest: ValidatedRequestData
  ) async throws {

    guard
        let uri = validatedAuthorizationRequest.request.responseUri,
        let responseUri = URL(string: uri)
    else {
        throw ValidationError.validationError("Invalid response uri")
    }
      
    self = .init(
        client: validatedAuthorizationRequest.request.client,
        nonce: validatedAuthorizationRequest.request.nonce,
        responseMode: validatedAuthorizationRequest.request.responseMode,
        responseUri: responseUri,
        state: validatedAuthorizationRequest.request.state,
        signatureQualifier: validatedAuthorizationRequest.request.signatureQualifier,
        documentDigests: validatedAuthorizationRequest.request.documentDigests,
        documentLocations: validatedAuthorizationRequest.request.documentLocations,
        hashAlgorithmOID: validatedAuthorizationRequest.request.hashAlgorithmOID,
        clientData: validatedAuthorizationRequest.request.clientData
    )
  }
}
