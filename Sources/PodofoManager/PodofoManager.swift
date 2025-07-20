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
import PoDoFo

public actor PodofoManager {
    
    private var podofoSessions: [PodofoSession] = []
    
    public init() {}
    
    public func calculateDocumentHashes(request: CalculateHashRequest, tsaUrl: String) async throws -> DocumentDigests {
        podofoSessions.removeAll()
        var hashes: [String] = []
        var c = 1
        
        try validateTsaUrlRequirement(
            for: request.documents,
            tsaUrl: tsaUrl
        )
        
        for doc in request.documents {
            
            do {
                let podofoWrapper = try PodofoWrapper(
                    conformanceLevel: doc.conformanceLevel.rawValue,
                    hashAlgorithm: request.hashAlgorithmOID.rawValue,
                    inputPath: doc.documentInputPath,
                    outputPath: doc.documentOutputPath,
                    certificate: request.endEntityCertificate,
                    chainCertificates: request.certificateChain
                )
                let session = PodofoSession(
                    id: "\(c)",
                    session: podofoWrapper,
                    conformanceLevel: doc.conformanceLevel,
                    endCertificate: request.endEntityCertificate,
                    chainCertificates: request.certificateChain
                )
                c += 1
                let hashOptional = podofoWrapper.calculateHash()
                if let hash = hashOptional {
                    hashes.append(hash)
                    podofoSessions.append(session)
                } else {
                    throw CalculateHashError.hashCalculationError(documentPath: doc.documentInputPath)
                }
            } catch {
                print("Failed to calculate hash for \(doc.documentInputPath): \(error)")
            }
        }
        
        let documentDigest = DocumentDigests(
            hashes: hashes
        )
        return documentDigest
    }

    public func createSignedDocuments(signatures: [String], tsaUrl: String) async throws {
        defer { podofoSessions.removeAll() }
        
        guard signatures.count == podofoSessions.count else {
            throw SigningError.mismatch(
                countSessions: podofoSessions.count,
                countSignatures: signatures.count
            )
        }

        for i in 0..<podofoSessions.count {
            var sessionWrapper = podofoSessions[i]
            let signedHash = signatures[i]
            sessionWrapper.session.printState()

            if sessionWrapper.conformanceLevel.rawValue == ConformanceLevel.ADES_B_B.rawValue {
                try await handleAdesB_B(sessionWrapper: sessionWrapper, signedHash: signedHash)
            } else if sessionWrapper.conformanceLevel.rawValue == ConformanceLevel.ADES_B_T.rawValue {
                try await handleAdesB_T(sessionWrapper: sessionWrapper, signedHash: signedHash, tsaUrl: tsaUrl)
            } else if sessionWrapper.conformanceLevel.rawValue == ConformanceLevel.ADES_B_LT.rawValue {
                try await handleAdesB_LT(sessionWrapper: sessionWrapper, signedHash: signedHash, tsaUrl: tsaUrl)
            } else if sessionWrapper.conformanceLevel.rawValue == ConformanceLevel.ADES_B_LTA.rawValue {
                try await handleAdesB_LTA(sessionWrapper: sessionWrapper, signedHash: signedHash, tsaUrl: tsaUrl)
            }
        }
    }
    
    private func handleAdesB_B(sessionWrapper: PodofoSession, signedHash: String) async throws {
        sessionWrapper.session.finalizeSigning(
            withSignedHash: signedHash,
            tsr: "",
            validationCertificates: [],
            validationCRLs: [],
            validationOCSPs: []
        )
    }
    
    private func handleAdesB_T(sessionWrapper: PodofoSession, signedHash: String, tsaUrl: String) async throws {
        print("Handling ADES-B-T...")
        let tsResponse = try await requestTimestamp(hash: signedHash, tsaUrl: tsaUrl)
        
        sessionWrapper.session.finalizeSigning(
            withSignedHash: signedHash,
            tsr: tsResponse.base64Tsr,
            validationCertificates: [],
            validationCRLs: [],
            validationOCSPs: []
        )
    }
    
    private func handleAdesB_LT(sessionWrapper: PodofoSession, signedHash: String, tsaUrl: String) async throws {
        let tsResponse = try await requestTimestamp(hash: signedHash, tsaUrl: tsaUrl)
        
        let validationCertificates = prepareValidationCertificates(
            sessionWrapper: sessionWrapper,
            timestampResponse: tsResponse.base64Tsr
        )

        let certificatesForCrlExtraction = [sessionWrapper.endCertificate] + sessionWrapper.chainCertificates
        var crlUrls: Set<String> = []
        
        for certificate in certificatesForCrlExtraction {
            let crlUrl = try sessionWrapper.session.getCrlFromCertificate(certificate)
            crlUrls.insert(crlUrl)
            print("CRL URL: \(crlUrl)")
        }
        
        let validationCrls = try await fetchCrlDataFromUrls(crlUrls: Array(crlUrls))
        
        sessionWrapper.session.finalizeSigning(
            withSignedHash: signedHash,
            tsr: tsResponse.base64Tsr,
            validationCertificates: validationCertificates,
            validationCRLs: validationCrls,
            validationOCSPs: []
        )
    }
    
    private func handleAdesB_LTA(sessionWrapper: PodofoSession, signedHash: String, tsaUrl: String) async throws {
        let tsResponse = try await requestTimestamp(hash: signedHash, tsaUrl: tsaUrl)
        
        let validationCertificates = prepareValidationCertificates(
            sessionWrapper: sessionWrapper,
            timestampResponse: tsResponse.base64Tsr
        )

        let certificatesForCrlExtraction = [sessionWrapper.endCertificate] + sessionWrapper.chainCertificates
        var crlUrls: Set<String> = []
        
        for certificate in certificatesForCrlExtraction {
            let crlUrl = try sessionWrapper.session.getCrlFromCertificate(certificate)
            crlUrls.insert(crlUrl)
            print("CRL URL: \(crlUrl)")
        }
        
        let validationCrls = try await fetchCrlDataFromUrls(crlUrls: Array(crlUrls))
        
        sessionWrapper.session.finalizeSigning(
            withSignedHash: signedHash,
            tsr: tsResponse.base64Tsr,
            validationCertificates: validationCertificates,
            validationCRLs: validationCrls,
            validationOCSPs: []
        )

        let ltaRawHash = try sessionWrapper.session.beginSigningLTA()
        let tsLtaResponse = try await requestTimestamp(hash: ltaRawHash, tsaUrl: tsaUrl)
        try sessionWrapper.session.finishSigningLTA(withTSR: tsLtaResponse.base64Tsr)
    }
    
    private func requestTimestamp(hash: String, tsaUrl: String) async throws -> TimestampResponse {
        let tsService = TimestampService()
        let tsRequest = TimestampRequest(
            hashToTimestamp: hash,
            tsaUrl: tsaUrl
        )
        return try await tsService.requestTimestamp(request: tsRequest)
    }
    
    private func prepareValidationCertificates(sessionWrapper: PodofoSession, timestampResponse: String) -> [String] {
        return [sessionWrapper.endCertificate] + sessionWrapper.chainCertificates + [timestampResponse]
    }
    
    private func fetchCrlDataFromUrls(crlUrls: [String]) async throws -> [String] {
        var validationCrlResponses: [String] = []
        let revocationService = RevocationService()
        
        for crlUrl in crlUrls {
            let crlRequest = CrlRequest(crlUrl: crlUrl)
            let crlInfo = try await revocationService.getCrlData(request: crlRequest)
            print("CRL Info Base64: \(crlInfo.crlInfoBase64)")
            validationCrlResponses.append(crlInfo.crlInfoBase64)
        }
        
        return validationCrlResponses
    }

    private func validateTsaUrlRequirement(
        for docs: [CalculateHashRequest.Document], tsaUrl: String
    ) throws {
        for doc in docs {
            if doc.conformanceLevel != .ADES_B_B && tsaUrl.isEmpty {
                throw CalculateHashError.missingTsaURL(
                    conformanceLevel: doc.conformanceLevel.rawValue)
            }
        }
    }
}
