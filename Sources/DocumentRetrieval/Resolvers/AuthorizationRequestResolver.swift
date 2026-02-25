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

public typealias Issuer = URL

public typealias JWTURI = String
public typealias JWTString = String
public typealias Nonce = String

public struct DocumentRetrievalConfiguration: Sendable {
    public let issuer: Issuer?
    public let supportedClientIdSchemes: [SupportedClientIdPrefix]
    public let session: Networking
    
    public init(
        issuer: Issuer?,
        supportedClientIdSchemes: [SupportedClientIdPrefix],
        session: Networking = URLSession.shared
    ) {
        self.issuer = issuer
        self.supportedClientIdSchemes = supportedClientIdSchemes
        self.session = session
    }
}

protocol AuthorizationRequestResolving: Sendable {
  func resolve(
    documentRetrievalConfiguration: DocumentRetrievalConfiguration,
    unvalidatedRequest: UnvalidatedRequest
  ) async throws -> AuthorizationRequest
}

public actor AuthorizationRequestResolver: AuthorizationRequestResolving {

  init() {}

  func resolve(
    documentRetrievalConfiguration: DocumentRetrievalConfiguration,
    unvalidatedRequest: UnvalidatedRequest
  ) async -> AuthorizationRequest {

      let clientAuthenticator: ClientAuthenticator = .init(
          config: documentRetrievalConfiguration
      )
      
    let requestAuthenticator: RequestAuthenticator = .init(
      config: documentRetrievalConfiguration,
      clientAuthenticator: clientAuthenticator
    )

    let fetchedRequest: FetchedRequest
    do {
      fetchedRequest = try await fetchRequest(
        config: documentRetrievalConfiguration,
        unvalidatedRequest: unvalidatedRequest
      )
    } catch {
      return .invalidResolution(
        error: ValidationError.validationError(error.localizedDescription)
      )
    }

    let authorizedRequest: AuthenticatedRequest
    do {
      authorizedRequest = try await authenticateRequest(
        requestAuthenticator: requestAuthenticator,
        config: documentRetrievalConfiguration,
        fetchedRequest: fetchedRequest
      )
    } catch {
      return .invalidResolution(
        error: ValidationError.validationError(error.localizedDescription)
      )
    }

    guard
      let unvalidatedResponseType = authorizedRequest.requestObject.responseType,
      let responseType = ResponseType(rawValue: unvalidatedResponseType)
    else {
      return .invalidResolution(
        error: ValidationError.missingResponseType
      )
    }

    guard let nonce = authorizedRequest.requestObject.nonce else {
      return .invalidResolution(
        error: ValidationError.missingNonce,
      )
    }

    let validated: ValidatedRequestData
    do {
      validated = try await createValidatedAuthorizationRequest(
        responseType: responseType,
        config: documentRetrievalConfiguration,
        requestAuthenticator: requestAuthenticator,
        authorizedRequest: authorizedRequest,
        nonce: nonce
      )
    } catch {
      return .invalidResolution(
        error: ValidationError.validationError(error.localizedDescription)
      )
    }

    let resolved: ResolvedRequestData
    do {
      resolved = try await resolveRequest(
        config: documentRetrievalConfiguration,
        validatedAuthorizationRequest: validated
      )
    } catch {
      return .invalidResolution(
        error: ValidationError.validationError(error.localizedDescription)
      )
    }

    return buildFinalRequest(
      fetchedRequest: fetchedRequest,
      resolved: resolved
    )
  }

  private func fetchRequest(
    config: DocumentRetrievalConfiguration,
    unvalidatedRequest: UnvalidatedRequest
  ) async throws -> FetchedRequest {
    try await RequestFetcher(
      config: config
    ).fetchRequest(request: unvalidatedRequest)
  }

  private func authenticateRequest(
    requestAuthenticator: RequestAuthenticator,
    config: DocumentRetrievalConfiguration,
    fetchedRequest: FetchedRequest
  ) async throws -> AuthenticatedRequest {
    return try await requestAuthenticator.authenticate(
      fetchRequest: fetchedRequest
    )
  }

  private func createValidatedAuthorizationRequest(
    responseType: ResponseType,
    config: DocumentRetrievalConfiguration,
    requestAuthenticator: RequestAuthenticator,
    authorizedRequest: AuthenticatedRequest,
    nonce: String
  ) async throws -> ValidatedRequestData {
    let clientId = authorizedRequest.client.id

    switch responseType {
    case .vpToken:
      return try await requestAuthenticator.createValidatedData(
        clientId: clientId,
        client: authorizedRequest.client,
        nonce: nonce,
        requestObject: authorizedRequest.requestObject
      )
    default:
      throw ValidationError.unsupportedResponseType(responseType.rawValue)
    }
  }

  private func resolveRequest(
    config: DocumentRetrievalConfiguration,
    validatedAuthorizationRequest: ValidatedRequestData
  ) async throws -> ResolvedRequestData {
    try await .init(
        config: config,
        validatedAuthorizationRequest: validatedAuthorizationRequest
    )
  }

  private func buildFinalRequest(
    fetchedRequest: FetchedRequest,
    resolved: ResolvedRequestData
  ) -> AuthorizationRequest {
    switch fetchedRequest {
    case .plain:
      return .notSecured(data: resolved)
    case .jwtSecured:
      return .jwt(request: resolved)
    }
  }
}
