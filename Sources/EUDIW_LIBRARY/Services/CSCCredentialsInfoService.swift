import Foundation

internal final actor CSCCredentialsInfoService: CSCCredentialsInfoServiceType {
    internal init() { }
    
    internal func getCredentialsInfo(request: CSCCredentialsInfoRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CSCCredentialsInfoResponse {

        try CSCCredentialsInfoValidator.validate(request)

        return try await CSCCredentialsInfoClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl:oauth2BaseUrl)
    }
}
