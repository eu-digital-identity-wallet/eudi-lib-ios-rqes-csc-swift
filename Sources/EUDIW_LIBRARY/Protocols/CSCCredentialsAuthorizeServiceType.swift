import Foundation

public protocol CSCCredentialsAuthorizeServiceType {

    func authorize(request: CSCCredentialsAuthorizeRequest, accessToken: String, oauth2BaseUrl:String) async throws -> CSCCredentialsAuthorizeResponse
}
