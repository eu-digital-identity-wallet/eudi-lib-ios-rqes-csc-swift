import Foundation

internal final actor SignHashService: SignHashServiceType {
    
    internal init() {}

    internal func signHash(request: SignHashRequest, accessToken: String, oauth2BaseUrl: String) async throws -> SignHashResponse {

        try SignHashValidator.validate(request: request)

        let response = try await SignHashClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl:oauth2BaseUrl)
        
        return response
    }
}
