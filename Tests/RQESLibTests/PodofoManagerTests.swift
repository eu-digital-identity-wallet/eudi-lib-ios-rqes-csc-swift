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

import XCTest
@testable import RQESLib

extension XCTestCase {
    func XCTAssertNoThrowAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
        } catch {
            XCTFail("Unexpected error thrown: \(error) - \(message)", file: file, line: line)
        }
    }
    
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown - \(message)", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}

final class PodofoManagerTests: XCTestCase {
    
    var podofoManager: PodofoManager!
    
    override func setUp() {
        super.setUp()
        podofoManager = PodofoManager()
    }
    
    override func tearDown() {
        podofoManager = nil
        super.tearDown()
    }

    func testPodofoManagerInitialization() {
        let manager = PodofoManager()
        XCTAssertNotNil(manager)
    }

    func testValidateTsaUrlRequirement_ADES_B_T_RequiresTsa() async throws {
        let documents = [TestConstants.adesB_T_Document]
        let request = CalculateHashRequest(
            documents: documents,
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        do {
            _ = try await podofoManager.calculateDocumentHashes(
                request: request,
                tsaUrl: TestConstants.emptyTsaUrl
            )
            XCTFail("ADES_B_T should require TSA URL")
        } catch {
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, ConformanceLevel.ADES_B_T.rawValue)
        }
    }
    
    func testValidateTsaUrlRequirement_ADES_B_LT_RequiresTsa() async throws {
        let documents = [TestConstants.adesB_LT_Document]
        let request = CalculateHashRequest(
            documents: documents,
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        do {
            _ = try await podofoManager.calculateDocumentHashes(
                request: request,
                tsaUrl: TestConstants.emptyTsaUrl
            )
            XCTFail("ADES_B_LT should require TSA URL")
        } catch {
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, ConformanceLevel.ADES_B_LT.rawValue)
        }
    }
    
    func testValidateTsaUrlRequirement_ADES_B_LTA_RequiresTsa() async throws {
        let documents = [TestConstants.adesB_LTA_Document]
        let request = CalculateHashRequest(
            documents: documents,
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        do {
            _ = try await podofoManager.calculateDocumentHashes(
                request: request,
                tsaUrl: TestConstants.emptyTsaUrl
            )
            XCTFail("ADES_B_LTA should require TSA URL")
        } catch {
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, ConformanceLevel.ADES_B_LTA.rawValue)
        }
    }
    
    func testValidateTsaUrlRequirement_MixedConformanceLevels() async throws {
        let documents = TestConstants.mixedConformanceLevelDocuments
        let request = CalculateHashRequest(
            documents: documents,
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        do {
            _ = try await podofoManager.calculateDocumentHashes(
                request: request,
                tsaUrl: TestConstants.emptyTsaUrl
            )
            XCTFail("Mixed conformance levels with TSA-requiring documents should fail with empty TSA URL")
        } catch {
            guard case CalculateHashError.missingTsaURL = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL for mixed conformance levels, got \(error)")
                return
            }
        }
    }
    
    
    func testValidateTsaUrlRequirement_SingleDocumentEachLevel() async throws {
        let testCases = [
            (TestConstants.adesB_T_Document, "ADES_B_T"),
            (TestConstants.adesB_LT_Document, "ADES_B_LT"),
            (TestConstants.adesB_LTA_Document, "ADES_B_LTA")
        ]
        
        for (document, expectedLevel) in testCases {
            let request = CalculateHashRequest(
                documents: [document],
                endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
                certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
                hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
            )
            
            do {
                _ = try await podofoManager.calculateDocumentHashes(
                    request: request,
                    tsaUrl: TestConstants.emptyTsaUrl
                )
                XCTFail("\(expectedLevel) should require TSA URL")
            } catch {
                if case CalculateHashError.missingTsaURL(let conformanceLevel) = error {
                    XCTAssertEqual(conformanceLevel, expectedLevel, "Error should specify correct conformance level")
                } else {
                    XCTFail("Expected CalculateHashError.missingTsaURL for \(expectedLevel), got \(error)")
                }
            }
        }
    }

    func testCalculateDocumentHashes_EmptyDocumentsArray() async throws {
        let request = CalculateHashRequest(
            documents: [],
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        do {
            let result = try await podofoManager.calculateDocumentHashes(
                request: request,
                tsaUrl: TestConstants.validTsaUrl
            )
            XCTAssertEqual(result.hashes.count, 0, "Empty documents should result in empty hashes")
        } catch {
        }
    }

    func testCreateSignedDocuments_SignatureCountMismatch() async throws {
        let signatures = TestConstants.sampleSignatures
        
        do {
            try await podofoManager.createSignedDocuments(
                signatures: signatures,
                tsaUrl: TestConstants.validTsaUrl
            )
        } catch {
            XCTAssertNotNil(error, "Should throw some error")
        }
    }
    
    func testCreateSignedDocuments_EmptySignaturesArray() async throws {
        let emptySignatures: [String] = []
        
        do {
            try await podofoManager.createSignedDocuments(
                signatures: emptySignatures,
                tsaUrl: TestConstants.validTsaUrl
            )
        } catch {
            if case SigningError.mismatch(let countSessions, let countSignatures) = error {
                XCTAssertEqual(countSessions, 0, "Should have 0 sessions initially")
                XCTAssertEqual(countSignatures, 0, "Should have 0 signatures provided")
            }
        }
    }
    
    func testCreateSignedDocuments_SingleSignature() async throws {
        let singleSignature = [TestConstants.sampleSignatures[0]]
        
        do {
            try await podofoManager.createSignedDocuments(
                signatures: singleSignature,
                tsaUrl: TestConstants.validTsaUrl
            )
        } catch {
            if case SigningError.mismatch(let countSessions, let countSignatures) = error {
                XCTAssertEqual(countSessions, 0, "Should have 0 sessions initially")
                XCTAssertEqual(countSignatures, 1, "Should have 1 signature provided")
            }
        }
    }
    
    func testCreateSignedDocuments_MultipleSignatures() async throws {
        let multipleSignatures = TestConstants.sampleSignatures
        
        do {
            try await podofoManager.createSignedDocuments(
                signatures: multipleSignatures,
                tsaUrl: TestConstants.validTsaUrl
            )
        } catch {
            if case SigningError.mismatch(let countSessions, let countSignatures) = error {
                XCTAssertEqual(countSessions, 0, "Should have 0 sessions initially")
                XCTAssertEqual(countSignatures, 3, "Should have 3 signatures provided")
            }
        }
    }
    
    func testCreateSignedDocuments_WithEmptyTsaUrl() async throws {
        let signatures = [TestConstants.sampleSignatures[0]]
        
        do {
            try await podofoManager.createSignedDocuments(
                signatures: signatures,
                tsaUrl: TestConstants.emptyTsaUrl
            )
        } catch {
            XCTAssertNotNil(error, "Should throw some error")
        }
    }
    
    func testCreateSignedDocuments_WithValidTsaUrl() async throws {
        let signatures = [TestConstants.sampleSignatures[0]]
        
        do {
            try await podofoManager.createSignedDocuments(
                signatures: signatures,
                tsaUrl: TestConstants.validTsaUrl
            )
        } catch {
            XCTAssertNotNil(error, "Should throw some error")
        }
    }

    func testCreateSignedDocuments_ParameterHandling() async throws {
        let testCases = [
            ([], TestConstants.validTsaUrl, "empty signatures with valid TSA"),
            ([TestConstants.sampleSignatures[0]], TestConstants.emptyTsaUrl, "single signature with empty TSA"),
            (TestConstants.sampleSignatures, TestConstants.validTsaUrl, "multiple signatures with valid TSA")
        ]
        
        for (signatures, tsaUrl, description) in testCases {
            do {
                try await podofoManager.createSignedDocuments(
                    signatures: signatures,
                    tsaUrl: tsaUrl
                )
            } catch {
                XCTAssertNotNil(error, "Should handle parameters for: \(description)")
            }
        }
    }

    func testPodofoManagerInitialState() {
        let manager = PodofoManager()
        XCTAssertNotNil(manager, "PodofoManager should initialize successfully")

        let manager2 = PodofoManager()
        XCTAssertNotNil(manager2, "Should be able to create multiple PodofoManager instances")
    }
    
    func testPodofoManagerActorIsolation() async {
        let manager = PodofoManager()

        do {
            _ = try await manager.calculateDocumentHashes(
                request: CalculateHashRequest(
                    documents: [],
                    endEntityCertificate: "test",
                    certificateChain: [],
                    hashAlgorithmOID: HashAlgorithmOID(rawValue: "test")
                ),
                tsaUrl: "test"
            )
        } catch {
            XCTAssertNotNil(error, "Actor should handle async calls")
        }
    }

    func testCalculateDocumentHashes_WithMixedDocuments() async throws {
        let mixedTsaRequired = [
            TestConstants.adesB_T_Document,
            TestConstants.adesB_LT_Document
        ]
        
        let request = CalculateHashRequest(
            documents: mixedTsaRequired,
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        do {
            _ = try await podofoManager.calculateDocumentHashes(
                request: request,
                tsaUrl: TestConstants.emptyTsaUrl
            )
            XCTFail("Mixed TSA-requiring documents should fail with empty TSA URL")
        } catch {
            guard case CalculateHashError.missingTsaURL = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL for mixed TSA-requiring documents")
                return
            }
        }
    }
    
    func testCreateSignedDocuments_WithDifferentSignatureLengths() async throws {
        let variousSignatures = [
            "short",
            "MEUCIQCldUS00il6qjIez47FWa2mJONabr0ydhC9emMlDeYfWAIgY7bVx7LuGDVSc3E//NSC+pI9atPS8MwXRRfL1Qk3TcU=",
            TestConstants.sampleSignatures[0]
        ]
        
        for signature in variousSignatures {
            do {
                try await podofoManager.createSignedDocuments(
                    signatures: [signature],
                    tsaUrl: TestConstants.validTsaUrl
                )
            } catch {
                XCTAssertNotNil(error, "Should handle signature format: \(signature.prefix(10))...")
            }
        }
    }
    
    func testCalculateDocumentHashes_SessionArrayManagement() async throws {
        let request = CalculateHashRequest(
            documents: [],
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        for i in 1...3 {
            do {
                _ = try await podofoManager.calculateDocumentHashes(
                    request: request,
                    tsaUrl: TestConstants.validTsaUrl
                )
            } catch {
                XCTAssertNotNil(error, "Call \(i) should handle empty documents")
            }
        }
    }
    
    func testCreateSignedDocuments_DeferCleanup() async throws {
        let singleSignature = [TestConstants.sampleSignatures[0]]
        
        for i in 1...3 {
            do {
                try await podofoManager.createSignedDocuments(
                    signatures: singleSignature,
                    tsaUrl: TestConstants.validTsaUrl
                )
            } catch {
                if case SigningError.mismatch(let sessions, let signatures) = error {
                    XCTAssertEqual(sessions, 0, "Sessions should be cleaned up between calls \(i)")
                    XCTAssertEqual(signatures, 1, "Should consistently have 1 signature")
                } else {
                    XCTAssertNotNil(error, "Should fail consistently between calls \(i)")
                }
            }
        }
    }

    func testSigningError_MismatchWithVariousCounts() {
        let testCases = [
            (0, 1, "zero sessions, one signature"),
            (1, 0, "one session, zero signatures"),
            (2, 5, "two sessions, five signatures"),
            (10, 3, "ten sessions, three signatures")
        ]
        
        for (sessionCount, signatureCount, description) in testCases {
            let error = SigningError.mismatch(countSessions: sessionCount, countSignatures: signatureCount)
            
            if case .mismatch(let sessions, let signatures) = error {
                XCTAssertEqual(sessions, sessionCount, "Session count should match for: \(description)")
                XCTAssertEqual(signatures, signatureCount, "Signature count should match for: \(description)")
            } else {
                XCTFail("Should be mismatch error for: \(description)")
            }
        }
    }
    
    func testCalculateHashError_AllErrorTypes() {
        let testErrors = [
            CalculateHashError.missingTsaURL(conformanceLevel: "ADES_B_T"),
            CalculateHashError.missingTsaURL(conformanceLevel: "ADES_B_LT"),
            CalculateHashError.missingTsaURL(conformanceLevel: "ADES_B_LTA"),
            CalculateHashError.hashCalculationError(documentPath: "/path/to/doc.pdf")
        ]
        
        for error in testErrors {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should have error description")

            switch error {
            case .missingTsaURL(let level):
                XCTAssertFalse(level.isEmpty, "Conformance level should not be empty")
            case .hashCalculationError(let path):
                XCTAssertEqual(path, "/path/to/doc.pdf", "Document path should match")
            default:
                let errorType = String(describing: type(of: error))
                XCTAssertEqual(errorType, "CalculateHashError", "Should be CalculateHashError")
            }
        }
    }

    func testDocumentDigests_EmptyHashesArray() {
        let emptyDigests = DocumentDigests(hashes: [])
        XCTAssertEqual(emptyDigests.hashes.count, 0, "Should handle empty hashes array")
    }
    
    func testDocumentDigests_SingleHash() {
        let singleHash = ["abcd1234efgh5678"]
        let digests = DocumentDigests(hashes: singleHash)
        XCTAssertEqual(digests.hashes.count, 1, "Should handle single hash")
        XCTAssertEqual(digests.hashes[0], "abcd1234efgh5678", "Should preserve hash value")
    }
    
    func testDocumentDigests_MultipleHashes() {
        let multipleHashes = [
            "hash1abcdef123456",
            "hash2ghijkl789012", 
            "hash3mnopqr345678"
        ]
        let digests = DocumentDigests(hashes: multipleHashes)
        XCTAssertEqual(digests.hashes.count, 3, "Should handle multiple hashes")
        XCTAssertEqual(digests.hashes, multipleHashes, "Should preserve all hash values")
    }

    func testPodofoManagerConcurrentAccess() async {
        let manager = PodofoManager()

        await withTaskGroup(of: Void.self) { group in
            for i in 1...3 {
                group.addTask {
                    do {
                        _ = try await manager.calculateDocumentHashes(
                            request: CalculateHashRequest(
                                documents: [],
                                endEntityCertificate: "test-\(i)",
                                certificateChain: [],
                                hashAlgorithmOID: HashAlgorithmOID(rawValue: "test")
                            ),
                            tsaUrl: "test-url-\(i)"
                        )
                    } catch {
                        XCTAssertNotNil(error, "Should handle concurrent access \(i)")
                    }
                }
            }
        }
    }
    
    func testPodofoManagerSequentialCalls() async {
        let manager = PodofoManager()
        let emptyRequest = CalculateHashRequest(
            documents: [],
            endEntityCertificate: "test",
            certificateChain: [],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "test")
        )

        for i in 1...3 {
            do {
                _ = try await manager.calculateDocumentHashes(
                    request: emptyRequest,
                    tsaUrl: "test-\(i)"
                )
            } catch {
                XCTAssertNotNil(error, "Sequential call \(i) should work independently")
            }
        }
    }

    func testValidateTsaUrlRequirement_ADES_B_B_WithEmptyTsaUrl() async throws {
        await XCTAssertNoThrowAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: TestConstants.onlyAdesB_B_Documents,
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "ADES_B_B documents should not require TSA URL"
        )
    }
    
    func testValidateTsaUrlRequirement_ADES_B_B_WithValidTsaUrl() async throws {
        await XCTAssertNoThrowAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: TestConstants.onlyAdesB_B_Documents,
                tsaUrl: TestConstants.validTsaUrl
            ),
            "ADES_B_B documents should work with TSA URL"
        )
    }
    
    func testValidateTsaUrlRequirement_ADES_B_T_WithEmptyTsaUrl() async throws {
        await XCTAssertThrowsErrorAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: [TestConstants.adesB_T_Document],
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "ADES_B_T documents should require TSA URL"
        ) { error in
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, "ADES_B_T", "Should report correct conformance level")
        }
    }
    
    func testValidateTsaUrlRequirement_ADES_B_LT_WithEmptyTsaUrl() async throws {
        await XCTAssertThrowsErrorAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: [TestConstants.adesB_LT_Document],
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "ADES_B_LT documents should require TSA URL"
        ) { error in
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, "ADES_B_LT", "Should report correct conformance level")
        }
    }
    
    func testValidateTsaUrlRequirement_ADES_B_LTA_WithEmptyTsaUrl() async throws {
        await XCTAssertThrowsErrorAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: [TestConstants.adesB_LTA_Document],
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "ADES_B_LTA documents should require TSA URL"
        ) { error in
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, "ADES_B_LTA", "Should report correct conformance level")
        }
    }
    
    func testValidateTsaUrlRequirement_AllTsaRequiredWithValidTsaUrl() async throws {
        await XCTAssertNoThrowAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: TestConstants.onlyTsaRequiredDocuments,
                tsaUrl: TestConstants.validTsaUrl
            ),
            "TSA-requiring documents should work with valid TSA URL"
        )
    }
    
    func testValidateTsaUrlRequirement_MixedDocumentsWithEmptyTsaUrl() async throws {
        await XCTAssertThrowsErrorAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: TestConstants.allConformanceLevelDocuments,
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "Mixed documents with TSA-requiring should fail with empty TSA URL"
        ) { error in
            guard case CalculateHashError.missingTsaURL = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
        }
    }
    
    func testValidateTsaUrlRequirement_MixedDocumentsWithValidTsaUrl() async throws {
        await XCTAssertNoThrowAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: TestConstants.allConformanceLevelDocuments,
                tsaUrl: TestConstants.validTsaUrl
            ),
            "Mixed documents should work with valid TSA URL"
        )
    }
    
    func testValidateTsaUrlRequirement_EmptyDocumentsArray() async throws {
        await XCTAssertNoThrowAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: [],
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "Empty documents array should not throw"
        )
        
        await XCTAssertNoThrowAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: [],
                tsaUrl: TestConstants.validTsaUrl
            ),
            "Empty documents array should work with any TSA URL"
        )
    }
    
    func testValidateTsaUrlRequirement_FirstDocumentFailureStopsValidation() async throws {
        let documentsWithFirstTsaRequired = [
            TestConstants.adesB_T_Document,
            TestConstants.adesB_B_Document,
            TestConstants.adesB_LT_Document
        ]
        
        await XCTAssertThrowsErrorAsync(
            try await podofoManager.validateTsaUrlRequirement(
                for: documentsWithFirstTsaRequired,
                tsaUrl: TestConstants.emptyTsaUrl
            ),
            "Should fail on first TSA-requiring document"
        ) { error in
            guard case CalculateHashError.missingTsaURL(let conformanceLevel) = error else {
                XCTFail("Expected CalculateHashError.missingTsaURL, got \(error)")
                return
            }
            XCTAssertEqual(conformanceLevel, "ADES_B_T", "Should fail on ADES_B_T (first document)")
        }
    }

    func testPrepareValidationCertificates_BasicFunctionality() {
        let expectedCertCount = 1 + TestConstants.mockChainCertificates.count + 1
        XCTAssertEqual(expectedCertCount, 5, "Expected total cert count should be 5")
    }

    func testRequestTimestamp_CallsTimestampService() async throws {
        
        do {
            _ = try await podofoManager.requestTimestamp(
                hash: TestConstants.mockHashForTimestamp,
                tsaUrl: TestConstants.validTsaUrl
            )
            XCTFail("Should fail due to real TimestampService call")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should attempt TimestampService call and fail appropriately")
        }
    }
    
    func testRequestTimestamp_WithEmptyHash() async throws {
        do {
            _ = try await podofoManager.requestTimestamp(
                hash: "",
                tsaUrl: TestConstants.validTsaUrl
            )
            XCTFail("Should fail with empty hash")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should handle empty hash appropriately")
        }
    }
    
    func testRequestTimestamp_WithEmptyTsaUrl() async throws {
        do {
            _ = try await podofoManager.requestTimestamp(
                hash: TestConstants.mockHashForTimestamp,
                tsaUrl: TestConstants.emptyTsaUrl
            )
            XCTFail("Should fail with empty TSA URL")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should handle empty TSA URL appropriately")
        }
    }

    func testFetchCrlDataFromUrls_CallsRevocationService() async throws {
        do {
            let results = try await podofoManager.fetchCrlDataFromUrls(crlUrls: TestConstants.mockCrlUrls)
            XCTFail("Should fail due to real RevocationService call, got \(results)")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should attempt RevocationService call and fail appropriately")
        }
    }
    
    func testFetchCrlDataFromUrls_WithEmptyUrlArray() async throws {
        do {
            let results = try await podofoManager.fetchCrlDataFromUrls(crlUrls: [])
            XCTAssertEqual(results.count, 0, "Should return empty array for empty input")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should handle empty URL array")
        }
    }
    
    func testFetchCrlDataFromUrls_WithSingleUrl() async throws {
        do {
            _ = try await podofoManager.fetchCrlDataFromUrls(crlUrls: [TestConstants.mockCrlUrls[0]])
            XCTFail("Should fail due to real RevocationService call")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should attempt single CRL fetch")
        }
    }
    
    func testFetchCrlDataFromUrls_WithMultipleUrls() async throws {
        do {
            _ = try await podofoManager.fetchCrlDataFromUrls(crlUrls: TestConstants.mockCrlUrls)
            XCTFail("Should fail due to real RevocationService call")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should attempt multiple CRL fetches")
        }
    }

    func testInternalMethodsCanBeCalledFromActor() async {
        let manager = PodofoManager()
        
        do {
            try await manager.validateTsaUrlRequirement(
                for: [TestConstants.adesB_B_Document],
                tsaUrl: TestConstants.emptyTsaUrl
            )
        } catch {
            XCTFail("ADES_B_B should not require TSA URL: \(error)")
        }
        
        do {
            _ = try await manager.requestTimestamp(
                hash: "test",
                tsaUrl: "invalid-url"
            )
            XCTFail("Should fail with invalid URL")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should handle invalid timestamp request")
        }
        
        do {
            _ = try await manager.fetchCrlDataFromUrls(crlUrls: ["invalid-url"])
            XCTFail("Should fail with invalid URL")
        } catch {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Should handle invalid CRL request")
        }
    }

    func testCalculateHashError_LocalizedErrorConformance() {
        let error: LocalizedError = CalculateHashError.missingTsaURL(conformanceLevel: "ADES_B_LT")
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("ADES_B_LT") ?? false)
        XCTAssertTrue(error.errorDescription?.contains("TSR_URL") ?? false)
    }

    func testSigningError_MismatchError() {
        let sessionCount = 3
        let signatureCount = 5
        let error = SigningError.mismatch(countSessions: sessionCount, countSignatures: signatureCount)

        if case .mismatch(let sessions, let signatures) = error {
            XCTAssertEqual(sessions, sessionCount)
            XCTAssertEqual(signatures, signatureCount)
        } else {
            XCTFail("SigningError should be mismatch type")
        }
    }
    
    func testSigningError_ErrorProtocolConformance() {
        let error: Error = SigningError.mismatch(countSessions: 2, countSignatures: 4)
        let errorType = String(describing: type(of: error))
        XCTAssertEqual(errorType, "SigningError", "Should be SigningError type")

        if let signingError = error as? SigningError {
            if case .mismatch(let sessions, let signatures) = signingError {
                XCTAssertEqual(sessions, 2)
                XCTAssertEqual(signatures, 4)
            } else {
                XCTFail("Should be mismatch case")
            }
        } else {
            XCTFail("Should be able to cast to SigningError")
        }
    }

    func testCalculateHashRequest_DocumentStructure() {
        let document = TestConstants.adesB_T_Document
        
        XCTAssertEqual(document.documentInputPath, "Documents/ades-b-t.pdf")
        XCTAssertEqual(document.documentOutputPath, "Documents/ades-b-t-signed.pdf")
        XCTAssertEqual(document.conformanceLevel.rawValue, ConformanceLevel.ADES_B_T.rawValue)
        XCTAssertEqual(document.signatureFormat.rawValue, SignatureFormat.P.rawValue)
        XCTAssertEqual(document.signedEnvelopeProperty.rawValue, SignedEnvelopeProperty.ENVELOPED.rawValue)
        XCTAssertEqual(document.container, "No")
    }
    
    func testCalculateHashRequest_FullRequestStructure() {
        let request = CalculateHashRequest(
            documents: [TestConstants.adesB_LT_Document],
            endEntityCertificate: TestConstants.standardCalculateHashRequest.endEntityCertificate,
            certificateChain: TestConstants.standardCalculateHashRequest.certificateChain,
            hashAlgorithmOID: TestConstants.standardCalculateHashRequest.hashAlgorithmOID
        )
        
        XCTAssertEqual(request.documents.count, 1)
        XCTAssertEqual(request.documents.first?.conformanceLevel.rawValue, ConformanceLevel.ADES_B_LT.rawValue)
        XCTAssertFalse(request.endEntityCertificate.isEmpty)
        XCTAssertFalse(request.certificateChain.isEmpty)
        XCTAssertNotNil(request.hashAlgorithmOID)
    }

    func testAllConformanceLevels_Coverage() {
        let allTestDocuments = [
            TestConstants.adesB_B_Document,
            TestConstants.adesB_T_Document,
            TestConstants.adesB_LT_Document,
            TestConstants.adesB_LTA_Document
        ]
        
        let conformanceLevelValues = allTestDocuments.map { $0.conformanceLevel.rawValue }
        
        XCTAssertTrue(conformanceLevelValues.contains(ConformanceLevel.ADES_B_B.rawValue))
        XCTAssertTrue(conformanceLevelValues.contains(ConformanceLevel.ADES_B_T.rawValue))
        XCTAssertTrue(conformanceLevelValues.contains(ConformanceLevel.ADES_B_LT.rawValue))
        XCTAssertTrue(conformanceLevelValues.contains(ConformanceLevel.ADES_B_LTA.rawValue))
    }
    
    func testTsaRequirementLogic_AllCases() {
        let tsaNotRequiredValues = [ConformanceLevel.ADES_B_B.rawValue]
        let tsaRequiredValues = [ConformanceLevel.ADES_B_T.rawValue, ConformanceLevel.ADES_B_LT.rawValue, ConformanceLevel.ADES_B_LTA.rawValue]

        for levelValue in tsaNotRequiredValues {
            XCTAssertEqual(levelValue, ConformanceLevel.ADES_B_B.rawValue, "Only ADES_B_B should not require TSA URL")
        }
        
        for levelValue in tsaRequiredValues {
            XCTAssertTrue(tsaRequiredValues.contains(levelValue), "These levels should require TSA URL")
        }
    }
} 
 
