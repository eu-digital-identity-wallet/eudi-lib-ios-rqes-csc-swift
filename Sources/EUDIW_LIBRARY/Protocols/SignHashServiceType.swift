import Foundation

public protocol SignHashServiceType {
    func signHash(request: SignHashRequest, accessToken: String, oauth2BaseUrl:String) async throws -> SignHashResponse
}
