import Foundation

public protocol CSCCredentialsListServiceType {
    func getCredentialsList(request: CSCCredentialsListRequest, accessToken: String, oauth2BaseUrl:String) async throws -> CSCCredentialsListResponse
}
