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
import SwiftyJSON

internal actor RequestFetcher {
  
  let config: DocumentRetrievalConfiguration
  
  init(config: DocumentRetrievalConfiguration) {
    self.config = config
  }
  
  func fetchRequest(request: UnvalidatedRequest) async throws -> FetchedRequest {
    
    switch request {
    case .plain(let object):
      return .plain(requestObject: object)
    case .jwtSecuredPassByValue(let clientId, let jwt):
      return .jwtSecured(clientId: clientId, jwt: jwt)
    case .jwtSecuredPassByReference(let clientId, let jwtURI, let requestURIMethod):
      let jwt = try await fetchJwt(
        clientId: clientId,
        jwtURI: jwtURI,
        requestURIMethod: requestURIMethod
      )
      return .jwtSecured(clientId: clientId, jwt: jwt)
    }
  }
  
  private func fetchJwt(
    clientId: String,
    jwtURI: URL,
    requestURIMethod: RequestUriMethod?
  ) async throws -> String {
    let method = requestURIMethod ?? .GET
    return try await getJWT(
      requestUriMethod: method,
      config: config,
      requestUrl: jwtURI,
      clientId: clientId
    ).jwt
  }
  
  private func getJWT(
    requestUriMethod: RequestUriMethod = .GET,
    config: DocumentRetrievalConfiguration?,
    requestUrl: URL,
    clientId: String?
  ) async throws -> (jwt: String, walletNonce: String?) {
    switch requestUriMethod {
    case .GET:
      let jwt = try await getJwtViaGET(
        config: config,
        clientId: clientId,
        requestUrl: requestUrl
      )
      return (jwt, nil)
    default:
        throw ValidationError.validationError("Invalid request uri method")
    }
  }
  
  private func getJwtViaGET(
    config: DocumentRetrievalConfiguration?,
    clientId: String?,
    requestUrl: URL
  ) async throws -> String {
    let jwt = try await getJwtString(
      fetcher: Fetcher(
        session: config?.session ?? URLSession.shared
      ),
      requestUrl: requestUrl
    )
    return jwt
  }
  
  fileprivate struct ResultType: Codable {}
  fileprivate func getJwtString(
    fetcher: Fetcher<ResultType> = Fetcher(),
    requestUrl: URL
  ) async throws -> String {
    let jwtResult = try await fetcher.fetchString(url: requestUrl)
    switch jwtResult {
    case .success(let string):
      return try extractJWT(string)
    case .failure: throw ValidationError.invalidJwtPayload
    }
  }
  
  /// Extracts the JWT token from a given JSON string or JWT string.
  /// - Parameter string: The input string containing either a JSON object with a JWT field or a JWT string.
  /// - Returns: The extracted JWT token.
  /// - Throws: An error of type `ValidatedAuthorizationError` if the input string is not a valid JSON or JWT, or if there's a decoding error.
  private func extractJWT(_ string: String) throws -> String {
    if string.isValidJSONString {
      if let jsonData = string.data(using: .utf8) {
        do {
          let decodedObject = try JSONDecoder().decode(RemoteJWT.self, from: jsonData)
          return decodedObject.jwt
        } catch {
          throw error
        }
      } else {
        throw ValidationError.invalidJwtPayload
      }
    } else {
      return string
    }
  }
}
