import Foundation

internal struct CSCCredentialsPushedAuthorizeValidator {

    internal static func validate(request: CSCCredentialsPushedAuthorizeRequest) throws {

        guard !request.clientId.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingClientId
        }

        guard request.responseType == "code" else {
            throw CSCCredentialsPushedAuthorizeError.invalidResponseType
        }

        guard !request.redirectUri.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingRedirectUri
        }

        guard !request.codeChallenge.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingCodeChallenge
        }

        guard request.codeChallengeMethod == "S256" else {
            throw CSCCredentialsPushedAuthorizeError.invalidCodeChallengeMethod
        }

        if let authorizationDetails = request.authorizationDetails {
            try validateAuthorizationDetails(authorizationDetails)
        }
    }

    internal static func validateAuthorizationDetails(_ details: AuthorizationDetails) throws {
        guard details.type == "credential" else {
            throw CSCCredentialsPushedAuthorizeError.invalidAuthorizationType
        }

        guard !details.credentialID.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingCredentialID
        }

        guard !details.documentDigests.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingDocumentDigests
        }

        for digest in details.documentDigests {
            try validateDocumentDigest(digest)
        }

        guard !details.hashAlgorithmOID.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingHashAlgorithmOID
        }
    }

    private static func validateDocumentDigest(_ digest: PushedAuthorizedDocumentDigest) throws {
        guard !digest.hash.isEmpty else {
            throw CSCCredentialsPushedAuthorizeError.missingHash
        }
    }
}
