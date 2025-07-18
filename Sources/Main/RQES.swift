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
import PoDoFo

public class RQES {
    private let infoService: InfoServiceType
    private let oauth2TokenService: OAuth2TokenServiceType
    private let credentialsListService: CredentialsListServiceType
    private let credentialsInfoService: CredentialsInfoServiceType
    private let signHashService: SignHashServiceType
    private let prepareAuthorizationRequestService: PrepareAuthorizationRequestServiceType 
    private var rsspId: String
    private var issuerURL: String
    private let cscClientConfig: CSCClientConfig
    private let podofoManager: PodofoManager
    
    public init(cscClientConfig: CSCClientConfig ) async {
        self.infoService = await ServiceLocator.shared.resolve() ?? InfoService()
        self.oauth2TokenService = await ServiceLocator.shared.resolve() ?? OAuth2TokenService()
        self.credentialsListService = await ServiceLocator.shared.resolve() ?? CredentialsListService()
        self.credentialsInfoService = await ServiceLocator.shared.resolve() ?? CredentialsInfoService()
        self.signHashService = await ServiceLocator.shared.resolve() ?? SignHashService()
        self.prepareAuthorizationRequestService = await ServiceLocator.shared.resolve() ?? PrepareAuthorizationRequestService()
        self.rsspId = cscClientConfig.rsspId
        self.cscClientConfig = cscClientConfig
        self.podofoManager = PodofoManager()
        self.issuerURL = ""
    }

    private func getInfo(request: InfoServiceRequest? = nil) async throws -> InfoServiceResponse {
        let response = try await infoService.getInfo(request: request, rsspUrl: self.rsspId)
        return response
    }

    public func requestAccessTokenAuthFlow(request: AccessTokenRequest) async throws -> AccessTokenResponse {
        return try await oauth2TokenService.getToken(request: request, cscClientConfig: self.cscClientConfig, issuerURL: self.issuerURL)
    }

    public func listCredentials(request: CredentialsListRequest, accessToken: String) async throws -> CredentialsListResponse {
        return try await credentialsListService.getCredentialsList(request: request, accessToken: accessToken, rsspUrl: self.rsspId)
    }

    public func getCredentialInfo(request: CredentialsInfoRequest, accessToken: String) async throws -> CredentialInfo {
        return try await credentialsInfoService.getCredentialsInfo(request: request, accessToken: accessToken, rsspUrl: self.rsspId)
    }

    public func signHash(request: SignHashRequest, accessToken: String) async throws -> SignHashResponse {
        return try await signHashService.signHash(request: request, accessToken: accessToken, rsspUrl: self.rsspId)
    }

    public func calculateDocumentHashes(request: CalculateHashRequest) async throws -> DocumentDigests {
        return try await podofoManager.calculateDocumentHashes(request: request, tsaUrl: cscClientConfig.tsaUrl)
    }

    public func createSignedDocuments(signatures: [String]) async throws {
        return try await podofoManager.createSignedDocuments(signatures: signatures, tsaUrl: cscClientConfig.tsaUrl)
    }
    
    public func prepareServiceAuthorizationRequest(walletState: String) async throws -> AuthorizationPrepareResponse {
        let infoResponse = try await getInfo()
        self.issuerURL = infoResponse.oauth2
        return try await prepareAuthorizationRequestService.prepareServiceRequest(walletState: walletState, cscClientConfig: self.cscClientConfig, issuerURL: self.issuerURL)
    }
    
    public func prepareCredentialAuthorizationRequest(walletState: String, authorizationDetails: String) async throws -> AuthorizationPrepareResponse {
        return try await prepareAuthorizationRequestService.prepareCredentialRequest(walletState: walletState, cscClientConfig: self.cscClientConfig, authorizationDetails: authorizationDetails, issuerURL: self.issuerURL)
    }
}
