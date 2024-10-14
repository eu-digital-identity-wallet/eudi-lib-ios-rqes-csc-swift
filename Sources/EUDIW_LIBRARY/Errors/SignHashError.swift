import Foundation

public enum SignHashError: LocalizedError {
    
    case invalidAuthorizationHeader
    case missingSAD
    case invalidSAD
    case expiredSAD
    case invalidOTP
    case missingCredentialID
    case invalidCredentialID
    case missingHashes
    case emptyHashes
    case invalidBase64Hash
    case unauthorizedHash
    case missingSignAlgo
    case invalidSignAlgo
    case missingHashAlgorithmOID
    case invalidHashAlgorithmOID
    case missingSignAlgoParams
    case invalidOperationMode
    case invalidValidityPeriod
    case outOfBoundsValidityPeriod
    case invalidResponseURI
    case invalidClientData
    case expiredCredential
    case invalidRequestURL
    case invalidResponse
    public var errorDescription: String? {
        switch self {
        case .invalidAuthorizationHeader:
            return "Malformed authorization header. The authorization header does not match the pattern 'Bearer [sessionKey]'."
        case .missingSAD:
            return "Missing or invalid 'SAD' parameter. The 'SAD' parameter is required."
        case .invalidSAD:
            return "Invalid 'SAD' parameter. The provided 'SAD' is not valid."
        case .expiredSAD:
            return "Expired 'SAD'. The Signature Activation Data (SAD) has expired."
        case .invalidOTP:
            return "Invalid OTP. The one-time password (OTP) used to generate the 'SAD' is invalid."
        case .missingCredentialID:
            return "Missing 'credentialID' parameter. The 'credentialID' parameter is required."
        case .invalidCredentialID:
            return "Invalid 'credentialID' parameter. The provided 'credentialID' is not valid."
        case .missingHashes:
            return "Missing or invalid 'hashes' parameter. At least one hash value is required."
        case .emptyHashes:
            return "Empty 'hashes' parameter. The 'hashes' array cannot be empty."
        case .invalidBase64Hash:
            return "Invalid Base64-encoded hash string. The provided 'hashes' contain an invalid Base64 element."
        case .unauthorizedHash:
            return "Hash is not authorized by the 'SAD'. The hash value provided is not authorized by the Signature Activation Data (SAD)."
        case .missingSignAlgo:
            return "Missing 'signAlgo' parameter. The 'signAlgo' parameter is required."
        case .invalidSignAlgo:
            return "Invalid 'signAlgo' parameter. The provided signing algorithm is not valid."
        case .missingHashAlgorithmOID:
            return "Missing 'hashAlgorithmOID' parameter. This is required when 'signAlgo' is not implicitly specifying the hash algorithm."
        case .invalidHashAlgorithmOID:
            return "Invalid 'hashAlgorithmOID' parameter. The provided hash algorithm OID is not valid."
        case .missingSignAlgoParams:
            return "Missing or invalid 'signAlgoParams' parameter. The 'signAlgoParams' parameter is required for certain algorithms."
        case .invalidOperationMode:
            return "Invalid 'operationMode' parameter. The 'operationMode' must be 'A' for asynchronous or 'S' for synchronous."
        case .invalidValidityPeriod:
            return "Invalid 'validity_period' parameter. The validity period must be a positive integer."
        case .outOfBoundsValidityPeriod:
            return "Out of bounds 'validity_period' parameter. The value provided is outside the allowed range."
        case .invalidResponseURI:
            return "Invalid 'response_uri' parameter. The 'response_uri' is not a valid URI."
        case .invalidClientData:
            return "Invalid 'clientData' parameter. The client data must be a string."
        case .expiredCredential:
            return "Signing certificate is expired. The credential's certificate has expired."
        case .invalidRequestURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        }
    }
 
    public var statusCode: Int {
        switch self {
        case .invalidAuthorizationHeader,
             .missingSAD, .invalidSAD, .expiredSAD, .invalidOTP,
             .missingCredentialID, .invalidCredentialID,
             .missingHashes, .emptyHashes, .invalidBase64Hash, .unauthorizedHash,
             .missingSignAlgo, .invalidSignAlgo,
             .missingHashAlgorithmOID, .invalidHashAlgorithmOID,
             .missingSignAlgoParams,
             .invalidOperationMode,
             .invalidValidityPeriod, .outOfBoundsValidityPeriod,
             .invalidResponseURI,
             .invalidClientData,
             .expiredCredential,
             .invalidRequestURL,
             .invalidResponse:
            return 400 
        }
    }
}
