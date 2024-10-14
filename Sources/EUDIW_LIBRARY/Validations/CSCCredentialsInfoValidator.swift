import Foundation

internal struct CSCCredentialsInfoValidator {

    internal static func validate(_ request: CSCCredentialsInfoRequest) throws {
        guard !request.credentialID.isEmpty else {
            throw CSCCredentialsInfoError.missingCredentialID
        }

        if let certificates = request.certificates {
            let validCertificates = ["none", "single", "chain"]
            guard validCertificates.contains(certificates) else {
                throw CSCCredentialsInfoError.invalidCertificates
            }
        }
    }
}
