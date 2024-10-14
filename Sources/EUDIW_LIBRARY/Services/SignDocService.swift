import Foundation

internal final actor SignDocService: SignDocServiceType {
    
    internal init() {}

    internal func signDoc(request: SignDocRequest, accessToken: String, oauth2BaseUrl: String) async throws -> SignDocResponse {

        try SignDocValidator.validate(request: request)

        let response = try await SignDocClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl:oauth2BaseUrl)
        
        return response
    }
}
