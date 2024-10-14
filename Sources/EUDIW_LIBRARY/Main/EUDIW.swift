import Foundation

public class EUDIW {

    private let infoService: InfoServiceType
    private let oauth2AuthorizeService: OAuth2AuthorizeServiceType
    private let oauth2TokenService: OAuth2TokenServiceType
    private let credentialsListService: CSCCredentialsListServiceType
    private let credentialsInfoService: CSCCredentialsInfoServiceType
    private let signHashService: SignHashServiceType
    private let signDocService: SignDocServiceType
    private let credentialsAuthorizeService: CSCCredentialsAuthorizeServiceType
    private let pushedAuthorizeService: CSCCredentialsPushedAuthorizeServiceType

    public init() async {
        // Resolve services asynchronously from the actor ServiceLocator
        self.infoService = await ServiceLocator.shared.resolve() ?? InfoService()
        self.oauth2AuthorizeService = await ServiceLocator.shared.resolve() ?? OAuth2AuthorizeService()
        self.oauth2TokenService = await ServiceLocator.shared.resolve() ?? OAuth2TokenService()
        self.credentialsListService = await ServiceLocator.shared.resolve() ?? CSCCredentialsListService()
        self.credentialsInfoService = await ServiceLocator.shared.resolve() ?? CSCCredentialsInfoService()
        self.signHashService = await ServiceLocator.shared.resolve() ?? SignHashService()
        self.signDocService = await ServiceLocator.shared.resolve() ?? SignDocService()
        self.credentialsAuthorizeService = await ServiceLocator.shared.resolve() ?? CSCCredentialsAuthorizeService()
        self.pushedAuthorizeService = await ServiceLocator.shared.resolve() ?? CSCCredentialsPushedAuthorizeService()
    }

    public func getInfo(request: InfoServiceRequest? = nil) async throws -> InfoServiceResponse {
        return try await infoService.getInfo(request: request)
    }

    public func getAuthorizeUrl(request: OAuth2AuthorizeRequest, oauth2BaseUrl: String) async throws -> OAuth2AuthorizeResponse {
        return try await oauth2AuthorizeService.authorize(request: request, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func getOAuth2Token(request: OAuth2TokenRequest, oauth2BaseUrl: String) async throws -> OAuth2TokenResponse {
        return try await oauth2TokenService.getToken(request: request, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func getCredentialsList(request: CSCCredentialsListRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsListResponse {
        return try await credentialsListService.getCredentialsList(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func getCredentialsInfo(request: CSCCredentialsInfoRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsInfoResponse {
        return try await credentialsInfoService.getCredentialsInfo(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func signHash(request: SignHashRequest, accessToken: String, oauth2BaseUrl: String) async throws -> SignHashResponse {
        return try await signHashService.signHash(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func signDoc(request: SignDocRequest, accessToken: String, oauth2BaseUrl: String) async throws -> SignDocResponse {
        return try await signDocService.signDoc(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func authorizeCredentials(request: CSCCredentialsAuthorizeRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsAuthorizeResponse {
        return try await credentialsAuthorizeService.authorize(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }

    public func pushedAuthorize(request: CSCCredentialsPushedAuthorizeRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsPushedAuthorizeResponse {
        return try await pushedAuthorizeService.pushedAuthorize(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }
}
