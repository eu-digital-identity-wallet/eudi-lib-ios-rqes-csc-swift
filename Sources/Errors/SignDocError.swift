/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

public enum SignDocError: LocalizedError {
    
    
    case invalidRequestURL
    case invalidResponse
    case invalidAuthorizationHeader
    case missingSAD
    case invalidSAD
    case expiredSAD
    case missingCredentialIDAndSignatureQualifier
    case missingCredentialID
    case invalidCredentialID
    case expiredCredential
    case missingDocumentDigestsAndDocuments
    case bothDocumentDigestsAndDocumentsPassed
    case emptyDocumentDigestsAndDocuments
    case emptyHashes
    case missingDocument
    case invalidDocumentDigests
    case invalidDocuments
    case invalidBase64Hashes
    case invalidBase64Documents
    case unauthorizedDocumentDigestsOrDocuments
    case invalidHashDigestLength
    case missingSignAlgo
    case invalidSignAlgo
    case missingSignAlgoParams
    case missingHashAlgorithmOID
    case invalidHashAlgorithmOID
    case missingSignatureFormat
    case invalidSignatureFormat
    case invalidConformanceLevel
    case invalidSignedEnvelopeProperty
    case invalidSignedProps
    case invalidOperationMode
    case invalidValidityPeriod
    case outOfBoundsValidityPeriod
    case invalidResponseURI
    case invalidClientData
    case invalidHashAuthorization
    case invalidReturnValidationInfo
    
    
    public var errorDescription: String? {
        switch self {
        case .invalidRequestURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidAuthorizationHeader:
            return "Malformed authorization header. The authorization header does not match the pattern 'Bearer [sessionKey]'."
        case .missingSAD:
            return "Missing 'SAD' parameter. The 'SAD' parameter is required."
        case .invalidSAD:
            return "Invalid 'SAD' parameter. The provided 'SAD' is invalid."
        case .expiredSAD:
            return "The 'SAD' has expired."
        case .missingCredentialIDAndSignatureQualifier:
            return "At least one of 'credentialID' or 'signatureQualifier' must be present."
        case .missingCredentialID:
            return "Missing 'credentialID' parameter. The 'credentialID' parameter is required."
        case .invalidCredentialID:
            return "Invalid 'credentialID' parameter. The provided 'credentialID' is invalid."
        case .expiredCredential:
            return "Signing certificate expired for 'O=[organization], CN=[common_name]'."
        case .missingDocumentDigestsAndDocuments:
            return "Either 'documentDigests' or 'documents' must be provided."
        case .bothDocumentDigestsAndDocumentsPassed:
            return "Both 'documentDigests' and 'documents' parameters have been passed. Only one should be provided."
        case .emptyDocumentDigestsAndDocuments:
            return "Both 'documentDigests' and 'documents' parameters are empty."
        case .emptyHashes:
            return "The 'hashes' array cannot be empty."
        case .missingDocument:
            return "Missing 'document' parameter. The 'document' is required."
        case .invalidDocumentDigests:
            return "Invalid 'documentDigests' object parameter."
        case .invalidDocuments:
            return "Invalid 'documents' array parameter."
        case .invalidBase64Hashes:
            return "Invalid Base64 hashes string parameter."
        case .invalidBase64Documents:
            return "Invalid Base64 documents string parameter."
        case .unauthorizedDocumentDigestsOrDocuments:
            return "The documentDigests or documents are not authorized by the 'SAD'."
        case .invalidHashDigestLength:
            return "Invalid digest value length for 'hashes' element."
        case .missingSignAlgo:
            return "Missing 'signAlgo' parameter. The 'signAlgo' parameter is required."
        case .invalidSignAlgo:
            return "Invalid 'signAlgo' parameter. The provided 'signAlgo' is invalid."
        case .missingSignAlgoParams:
            return "Missing 'signAlgoParams' parameter. The 'signAlgoParams' is required."
        case .missingHashAlgorithmOID:
            return "Missing 'hashAlgorithmOID' parameter."
        case .invalidHashAlgorithmOID:
            return "'hashAlgorithmOID' contradicts with 'signAlgo' or is invalid."
        case .missingSignatureFormat:
            return "Missing 'signature_format' parameter. The 'signature_format' is required."
        case .invalidSignatureFormat:
            return "Invalid 'signature_format' parameter."
        case .invalidConformanceLevel:
            return "Invalid 'conformance_level' parameter."
        case .invalidSignedEnvelopeProperty:
            return "Invalid 'signed_envelope_property' parameter."
        case .invalidSignedProps:
            return "Invalid 'signed_props' parameter. The list of attributes is invalid."
        case .invalidOperationMode:
            return "Invalid 'operationMode' parameter."
        case .invalidValidityPeriod:
            return "Invalid 'validity_period' parameter."
        case .outOfBoundsValidityPeriod:
            return "'validity_period' value is out of bounds."
        case .invalidResponseURI:
            return "Invalid 'response_uri' parameter."
        case .invalidClientData:
            return "Invalid 'clientData' parameter. The 'clientData' must be a string."
        case .invalidHashAuthorization:
            return "Document or documentDigest does not match authorized hash."
        case .invalidReturnValidationInfo:
            return "Invalid returnValidationInfo. The validation info returned is invalid."
        }
    }
}
