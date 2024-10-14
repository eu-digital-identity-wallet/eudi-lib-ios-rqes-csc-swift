import Foundation

internal final actor CSCCredentialsPushedAuthorizeService: CSCCredentialsPushedAuthorizeServiceType {

    internal init() {}

    internal func pushedAuthorize(
        request: CSCCredentialsPushedAuthorizeRequest,
        accessToken: String, oauth2BaseUrl:String
    ) async throws -> CSCCredentialsPushedAuthorizeResponse {

        try CSCCredentialsPushedAuthorizeValidator.validate(request: request)


        let response = try await CSCCredentialsPushedAuthorizeClient.sendPushedAuthorizeRequest(
            for: request,
            accessToken: accessToken,
            oauth2BaseUrl:oauth2BaseUrl
        )

        return response
    }
}
