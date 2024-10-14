import Foundation

internal struct SignHashValidator {

    internal static func validate(request: SignHashRequest) throws {

        guard !request.credentialID.isEmpty else {
            throw SignHashError.missingCredentialID
        }

        if request.SAD == nil && request.operationMode != "credential" {
            throw SignHashError.missingSAD
        }

        guard !request.hashes.isEmpty else {
            throw SignHashError.missingHashes
        }
        
        for hash in request.hashes {
            if !isValidBase64(hash) {
                throw SignHashError.invalidBase64Hash
            }
        }

        if request.hashAlgorithmOID.isEmpty && request.signAlgo != "1.2.840.113549.1.1.1" {
            throw SignHashError.missingHashAlgorithmOID
        }

        guard !request.signAlgo.isEmpty else {
            throw SignHashError.missingSignAlgo
        }

        if let operationMode = request.operationMode {
            if !["A", "S"].contains(operationMode) {
                throw SignHashError.invalidOperationMode
            }
        }

        if request.operationMode == "A", let validityPeriod = request.validityPeriod {
            guard validityPeriod > 0 else {
                throw SignHashError.invalidValidityPeriod
            }
        }

        if request.operationMode == "A", let responseURI = request.responseURI {
            guard !responseURI.isEmpty else {
                throw SignHashError.invalidResponseURI
            }
        }
    }

    private static func isValidBase64(_ string: String) -> Bool {
        return Data(base64Encoded: string) != nil
    }
}
