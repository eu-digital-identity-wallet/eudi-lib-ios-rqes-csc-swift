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

final actor PrepareAuthorizationRequestService: PrepareAuthorizationRequestServiceType {
    init() { }

    func prepareServiceRequest(walletState: String, cscClientConfig: CSCClientConfig, issuerURL: String) async throws -> AuthorizationPrepareResponse {
   
        let codeChallenge = try await PKCEState.shared.initializeAndGetCodeChallenge()
     
        guard var components = URLComponents(string: issuerURL + "/oauth2/authorize") else {
            throw ClientError.invalidRequestURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: cscClientConfig.OAuth2Client.clientId),
            URLQueryItem(name: "redirect_uri", value: cscClientConfig.authFlowRedirectionURI),
            URLQueryItem(name: "scope", value: Scope.SERVICE.rawValue),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: walletState),
        ]
        
        guard let authorizationCodeURL = components.url?.absoluteString else {
            throw ClientError.invalidRequestURL
        }
        
        return AuthorizationPrepareResponse(authorizationCodeURL: authorizationCodeURL)
    }
    
    func prepareCredentialRequest(walletState: String, cscClientConfig: CSCClientConfig, authorizationDetails: String, issuerURL: String) async throws -> AuthorizationPrepareResponse {
       
        let codeChallenge = try await PKCEState.shared.initializeAndGetCodeChallenge()
   
        guard var components = URLComponents(string: issuerURL + "/oauth2/authorize") else {
            throw ClientError.invalidRequestURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: cscClientConfig.OAuth2Client.clientId),
            URLQueryItem(name: "redirect_uri", value: cscClientConfig.authFlowRedirectionURI),
            URLQueryItem(name: "scope", value: Scope.CREDENTIAL.rawValue),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: walletState),
            URLQueryItem(name: "authorization_details", value: authorizationDetails)
        ]
        
        guard let authorizationCodeURL = components.url?.absoluteString else {
            throw ClientError.invalidRequestURL
        }
        
        return AuthorizationPrepareResponse(authorizationCodeURL: authorizationCodeURL)
    }
}
