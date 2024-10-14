import Foundation

public protocol SignDocServiceType {
    func signDoc(request: SignDocRequest, accessToken: String, oauth2BaseUrl:String) async throws -> SignDocResponse
}
