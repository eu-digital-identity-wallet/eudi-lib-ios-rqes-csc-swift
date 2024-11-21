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

public class RQES {
    private let infoService: InfoServiceType
    private let oauth2AuthorizeService: OAuth2AuthorizeServiceType
    private let oauth2TokenService: OAuth2TokenServiceType
    private let credentialsListService: CSCCredentialsListServiceType
    private let credentialsInfoService: CSCCredentialsInfoServiceType
    private let signHashService: SignHashServiceType
    private let calculateHashService: CalculateHashServiceType
    private let obtainSignedDocService: ObtainSignedDocServiceType
    private let prepareAuthorizationRequestService: PrepareAuthorizationRequestServiceType 
    private var baseProviderUrl: String
    private let cscClientConfig: CSCClientConfig
    
    public init(cscClientConfig: CSCClientConfig ) async {
        self.infoService = await ServiceLocator.shared.resolve() ?? InfoService()
        self.oauth2AuthorizeService = await ServiceLocator.shared.resolve() ?? OAuth2AuthorizeService()
        self.oauth2TokenService = await ServiceLocator.shared.resolve() ?? OAuth2TokenService()
        self.credentialsListService = await ServiceLocator.shared.resolve() ?? CSCCredentialsListService()
        self.credentialsInfoService = await ServiceLocator.shared.resolve() ?? CSCCredentialsInfoService()
        self.signHashService = await ServiceLocator.shared.resolve() ?? SignHashService()
        self.calculateHashService = await ServiceLocator.shared.resolve() ?? CalculateHashService()
        self.obtainSignedDocService = await ServiceLocator.shared.resolve() ?? ObtainSignedDocService()
        self.prepareAuthorizationRequestService = await ServiceLocator.shared.resolve() ?? PrepareAuthorizationRequestService()
        self.baseProviderUrl = cscClientConfig.scaBaseURL
        self.cscClientConfig = cscClientConfig
    }

    public func getInfo(request: InfoServiceRequest? = nil) async throws -> InfoServiceResponse {
        let response = try await infoService.getInfo(request: request)
        self.baseProviderUrl = response.oauth2
        return response
    }

    public func getAuthorizeUrl(request: OAuth2AuthorizeRequest) async throws -> OAuth2AuthorizeResponse {
        return try await oauth2AuthorizeService.authorize(request: request, oauth2BaseUrl: self.baseProviderUrl)
    }

    public func getOAuth2Token(request: OAuth2TokenDto) async throws -> OAuth2TokenResponse {
        return try await oauth2TokenService.getToken(request: request, cscClientConfig: self.cscClientConfig)
    }

    public func getCredentialsList(request: CSCCredentialsListRequest, accessToken: String) async throws -> CSCCredentialsListResponse {
        return try await credentialsListService.getCredentialsList(request: request, accessToken: accessToken, oauth2BaseUrl: self.baseProviderUrl)
    }

    public func getCredentialsInfo(request: CSCCredentialsInfoRequest, accessToken: String) async throws -> CSCCredentialsInfoResponse {
        return try await credentialsInfoService.getCredentialsInfo(request: request, accessToken: accessToken, oauth2BaseUrl: self.baseProviderUrl)
    }

    public func signHash(request: SignHashRequest, accessToken: String) async throws -> SignHashResponse {
        return try await signHashService.signHash(request: request, accessToken: accessToken, oauth2BaseUrl: self.baseProviderUrl)
    }

    public func calculateHash(request: CalculateHashRequest, accessToken: String) async throws -> CalculateHashResponse {
        return try await calculateHashService.calculateHash(request: request, accessToken: accessToken, oauth2BaseUrl: self.baseProviderUrl)
    }

    public func obtainSignedDoc(request: ObtainSignedDocRequest, accessToken: String) async throws -> ObtainSignedDocResponse {
        return try await obtainSignedDocService.obtainSignedDoc(request: request, accessToken: accessToken, oauth2BaseUrl: self.baseProviderUrl)
    }
    
    public func prepareServiceAuthorizationRequest(walletState: String) async throws -> AuthorizationPrepareResponse {
        return try await prepareAuthorizationRequestService.prepareServiceRequest(walletState: walletState, cscClientConfig: self.cscClientConfig )
    }
    
    public func prepareCredentialAuthorizationRequest(walletState: String, authorizationDetails: String) async throws -> AuthorizationPrepareResponse {
        return try await prepareAuthorizationRequestService.prepareCredentialRequest(walletState: walletState, cscClientConfig: self.cscClientConfig, authorizationDetails: authorizationDetails )
    }
}
