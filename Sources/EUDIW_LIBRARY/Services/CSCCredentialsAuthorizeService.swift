import Foundation

internal final actor CSCCredentialsAuthorizeService: CSCCredentialsAuthorizeServiceType {

    internal init() {}

    internal func authorize(request: CSCCredentialsAuthorizeRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsAuthorizeResponse {

        try CSCCredentialsAuthorizeValidator.validate(request: request)

        let response = try await CSCCredentialsAuthorizeClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl:oauth2BaseUrl)
        
        return response
    }
}
