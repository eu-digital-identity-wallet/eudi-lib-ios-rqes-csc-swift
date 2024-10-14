import Foundation

public protocol OAuth2AuthorizeServiceType{
    func authorize(request: OAuth2AuthorizeRequest, oauth2BaseUrl:String) async throws -> OAuth2AuthorizeResponse
}
