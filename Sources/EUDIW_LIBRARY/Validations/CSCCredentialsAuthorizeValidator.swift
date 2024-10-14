import Foundation

internal struct CSCCredentialsAuthorizeValidator {

    internal static func validate(request: CSCCredentialsAuthorizeRequest) throws {

        if request.credentialID.isEmpty {
            throw CSCCredentialsAuthorizeError.missingCredentialID
        }

        guard request.numSignatures > 0 else {
            throw CSCCredentialsAuthorizeError.invalidNumSignatures
        }

        if let hashes = request.hashes {
            guard !hashes.isEmpty else {
                throw CSCCredentialsAuthorizeError.missingHashes
            }
            for hash in hashes {
                guard !hash.isEmpty else {
                    throw CSCCredentialsAuthorizeError.invalidHashValue
                }
            }
        } else {
            throw CSCCredentialsAuthorizeError.missingHashes
        }

        guard let hashAlgorithmOID = request.hashAlgorithmOID, !hashAlgorithmOID.isEmpty else {
            throw CSCCredentialsAuthorizeError.missingHashAlgorithmOID
        }

        if let authData = request.authData {
            guard !authData.isEmpty else {
                throw CSCCredentialsAuthorizeError.missingAuthData
            }
            for auth in authData {
                guard !auth.id.isEmpty, !auth.value.isEmpty else {
                    throw CSCCredentialsAuthorizeError.invalidAuthData
                }
            }
        }
    }
}
