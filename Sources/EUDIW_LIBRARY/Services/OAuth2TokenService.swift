import Foundation

internal final actor OAuth2TokenService: OAuth2TokenServiceType {

    internal init() { } 

    internal func getToken(request: OAuth2TokenRequest, oauth2BaseUrl: String) async throws -> OAuth2TokenResponse {
        try OAuth2TokenValidator.validate(request)
        return try await OAuth2TokenClient.makeRequest(for: request, oauth2BaseUrl:oauth2BaseUrl)
    }
}
