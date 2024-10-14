import Foundation

internal final actor OAuth2AuthorizeService: OAuth2AuthorizeServiceType {

    internal init() {}

    internal func authorize(request: OAuth2AuthorizeRequest, oauth2BaseUrl: String) async throws -> OAuth2AuthorizeResponse {

        try OAuth2AuthorizeValidator.validate(request)

        return try await OAuth2AuthorizeClient.makeRequest(for: request, oauth2BaseUrl: oauth2BaseUrl)
    }
}
