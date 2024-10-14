import Foundation

internal final actor CSCCredentialsListService: CSCCredentialsListServiceType {
    
    internal init() {}
    internal func getCredentialsList(request: CSCCredentialsListRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsListResponse {
        return try await CSCCredentialsListClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl:oauth2BaseUrl)
    }
}
