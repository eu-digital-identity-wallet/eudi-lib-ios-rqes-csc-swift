import Foundation

internal struct OAuth2TokenValidator {

    internal static func validate(_ request: OAuth2TokenRequest) throws {
        guard !request.clientId.isEmpty else {
            throw OAuth2TokenError.missingClientId
        }
        
        guard !request.grantType.isEmpty else {
            throw OAuth2TokenError.missingGrantType
        }
        
        if request.grantType == "authorization_code" {
            guard let redirectUri = request.redirectUri, !redirectUri.isEmpty else {
                throw OAuth2TokenError.missingRedirectUri
            }
        }
    }
}
