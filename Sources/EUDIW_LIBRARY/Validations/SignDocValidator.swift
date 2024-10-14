import Foundation

internal struct SignDocValidator {

    internal static func validate(request: SignDocRequest) throws {

        if request.credentialID == nil && request.signatureQualifier == nil {
            throw SignDocError.missingCredentialIDAndSignatureQualifier
        }

        if request.documentDigests == nil && request.documents == nil {
            throw SignDocError.missingDocumentDigestsAndDocuments
        }

        if let documentDigests = request.documentDigests {
            for digest in documentDigests {
                if digest.hashes.isEmpty {
                    throw SignDocError.emptyHashes
                }
            }
        }

        if let documents = request.documents {
            for document in documents {
                if document.document.isEmpty {
                    throw SignDocError.missingDocument
                }
            }
        }

        if let operationMode = request.operationMode {
            if operationMode != "A" {
                throw SignDocError.invalidValidityPeriod
            }
        }

        if let returnValidationInfo = request.returnValidationInfo, returnValidationInfo {
            guard let document = request.documents?.first else { return }
            if document.signatureFormat != "P" {
                throw SignDocError.invalidReturnValidationInfo
            }
        }
    }
}
