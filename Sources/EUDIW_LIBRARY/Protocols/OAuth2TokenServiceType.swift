import Foundation

public protocol OAuth2TokenServiceType {
    func getToken(request: OAuth2TokenRequest, oauth2BaseUrl:String) async throws -> OAuth2TokenResponse
}
