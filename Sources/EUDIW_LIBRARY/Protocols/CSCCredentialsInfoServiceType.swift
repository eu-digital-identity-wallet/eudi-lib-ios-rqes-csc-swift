import Foundation

public protocol CSCCredentialsInfoServiceType {
    func getCredentialsInfo(request: CSCCredentialsInfoRequest, accessToken: String, oauth2BaseUrl:String) async throws -> CSCCredentialsInfoResponse
}
