import Foundation

internal struct OAuth2AuthorizeValidator {
    
    private static let requiredResponseType = "code"

    internal static func validate(_ request: OAuth2AuthorizeRequest) throws {
        guard request.responseType == requiredResponseType else {
            throw OAuth2AuthorizeError.invalidResponseType
        }

        guard !request.clientId.isEmpty else {
            throw OAuth2AuthorizeError.missingClientId
        }

        guard !request.redirectUri.isEmpty else {
            throw OAuth2AuthorizeError.missingRedirectUri
        }

        guard !request.codeChallenge.isEmpty else {
            throw OAuth2AuthorizeError.missingCodeChallenge
        }
        guard !request.codeChallengeMethod.isEmpty else {
            throw OAuth2AuthorizeError.missingCodeChallengeMethod
        }

        try validateConditionalFields(for: request)
    }

    private static func validateConditionalFields(for request: OAuth2AuthorizeRequest) throws {
        if request.scope == "credential" {
            guard let credentialID = request.credentialID, !credentialID.isEmpty else {
                throw OAuth2AuthorizeError.missingCredentialID
            }
            
            if request.numSignatures != nil && request.hashes == nil {
                throw OAuth2AuthorizeError.missingHashesForMultipleSignatures
            }
        }
        
        if let authorizationDetails = request.authorizationDetails, authorizationDetails.isEmpty {
            throw OAuth2AuthorizeError.invalidAuthorizationDetails
        }
    }
}
