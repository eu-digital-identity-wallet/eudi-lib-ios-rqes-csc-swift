import Foundation

public protocol CSCCredentialsPushedAuthorizeServiceType {

    func pushedAuthorize(request: CSCCredentialsPushedAuthorizeRequest, accessToken: String, oauth2BaseUrl:String) async throws -> CSCCredentialsPushedAuthorizeResponse
}
