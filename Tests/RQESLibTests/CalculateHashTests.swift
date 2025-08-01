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

final class CalculateHashTests: XCTestCase {

    func testCalculateHashRequestJSONDecoding() throws {
        let data = TestConstants.calculateHashRequest.data(using: .utf8)!
        let request = try JSONDecoder().decode(CalculateHashRequest.self, from: data)
        
        XCTAssertEqual(request.documents.count, 1)
        XCTAssertEqual(request.documents[0].documentInputPath, "Documents/sample.pdf")
        XCTAssertEqual(request.documents[0].documentOutputPath, "Documents/sample-signed.pdf")
        XCTAssertEqual(request.documents[0].signatureFormat.rawValue, "P")
        XCTAssertEqual(request.documents[0].conformanceLevel.rawValue, "ADES_B_LT")
        XCTAssertEqual(request.documents[0].signedEnvelopeProperty.rawValue, "ENVELOPED")
        XCTAssertEqual(request.documents[0].container, "No")
        
        XCTAssertEqual(request.hashAlgorithmOID.rawValue, "2.16.840.1.101.3.4.2.3")
        XCTAssertEqual(request.certificateChain.count, 1)
        XCTAssertTrue(request.endEntityCertificate.hasPrefix("MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeM"))
    }
    
    func testCalculateHashRequestJSONEncoding() throws {
        let request = TestConstants.standardCalculateHashRequest
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertNotNil(json["documents"])
        XCTAssertNotNil(json["endEntityCertificate"])
        XCTAssertNotNil(json["certificateChain"])
        XCTAssertNotNil(json["hashAlgorithmOID"])
        
        let documents = json["documents"] as! [[String: Any]]
        XCTAssertEqual(documents.count, 1)
        XCTAssertEqual(documents[0]["documentInputPath"] as? String, "Documents/sample.pdf")
        XCTAssertEqual(documents[0]["signature_format"] as? String, "P")
        XCTAssertEqual(documents[0]["conformance_level"] as? String, "ADES_B_LT")
        XCTAssertEqual(documents[0]["signed_envelope_property"] as? String, "ENVELOPED")
    }
    
    func testCalculateHashRequestMinimalJSON() throws {
        let data = TestConstants.minimalCalculateHashRequest.data(using: .utf8)!
        let request = try JSONDecoder().decode(CalculateHashRequest.self, from: data)
        
        XCTAssertEqual(request.documents.count, 1)
        XCTAssertEqual(request.documents[0].documentInputPath, "test.pdf")
        XCTAssertEqual(request.documents[0].signatureFormat.rawValue, "P")
        XCTAssertEqual(request.documents[0].conformanceLevel.rawValue, "ADES_B_LT")
        XCTAssertEqual(request.hashAlgorithmOID.rawValue, "2.16.840.1.101.3.4.2.1")
        XCTAssertEqual(request.certificateChain.count, 1)
        XCTAssertEqual(request.certificateChain[0], "CERT1")
    }
    
    func testCalculateHashRequestMultipleDocuments() throws {
        let data = TestConstants.multipleDocumentsCalculateHashRequest.data(using: .utf8)!
        let request = try JSONDecoder().decode(CalculateHashRequest.self, from: data)
        
        XCTAssertEqual(request.documents.count, 2)
        XCTAssertEqual(request.documents[0].documentInputPath, "doc1.pdf")
        XCTAssertEqual(request.documents[0].signatureFormat.rawValue, "P")
        XCTAssertEqual(request.documents[1].documentInputPath, "doc2.pdf")
        XCTAssertEqual(request.documents[1].signatureFormat.rawValue, "C")
        XCTAssertEqual(request.documents[1].container, "ASiC-S")
        XCTAssertEqual(request.certificateChain.count, 2)
    }
    
    func testCalculateHashRequestDocumentInitializer() {
        let document = CalculateHashRequest.Document(
            documentInputPath: "input.pdf",
            documentOutputPath: "output.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "ASiC-S"
        )
        
        XCTAssertEqual(document.documentInputPath, "input.pdf")
        XCTAssertEqual(document.documentOutputPath, "output.pdf")
        XCTAssertEqual(document.signatureFormat.rawValue, "P")
        XCTAssertEqual(document.conformanceLevel.rawValue, "ADES_B_B")
        XCTAssertEqual(document.signedEnvelopeProperty.rawValue, "ENVELOPED")
        XCTAssertEqual(document.container, "ASiC-S")
    }
    
    func testCalculateHashRequestInitializer() {
        let document = CalculateHashRequest.Document(
            documentInputPath: "test.pdf",
            documentOutputPath: "test-signed.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let request = CalculateHashRequest(
            documents: [document],
            endEntityCertificate: "CERT",
            certificateChain: ["CHAIN_CERT"],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
        )
        
        XCTAssertEqual(request.documents.count, 1)
        XCTAssertEqual(request.documents[0].documentInputPath, "test.pdf")
        XCTAssertEqual(request.endEntityCertificate, "CERT")
        XCTAssertEqual(request.certificateChain.count, 1)
        XCTAssertEqual(request.certificateChain[0], "CHAIN_CERT")
        XCTAssertEqual(request.hashAlgorithmOID.rawValue, "2.16.840.1.101.3.4.2.1")
    }
    
    func testCalculateHashRequestCodingKeys() throws {
        let data = TestConstants.calculateHashRequest.data(using: .utf8)!
        let request = try JSONDecoder().decode(CalculateHashRequest.self, from: data)

        let encoded = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        
        XCTAssertNotNil(json["endEntityCertificate"])
        XCTAssertNotNil(json["certificateChain"])
        XCTAssertNotNil(json["hashAlgorithmOID"])
        XCTAssertNotNil(json["documents"])
        
        let documents = json["documents"] as! [[String: Any]]
        let document = documents[0]
        XCTAssertNotNil(document["signature_format"])
        XCTAssertNotNil(document["conformance_level"])
        XCTAssertNotNil(document["signed_envelope_property"])
    }

    func testDocumentDigestsJSONDecoding() throws {
        let data = TestConstants.documentDigestsResponse.data(using: .utf8)!
        let response = try JSONDecoder().decode(DocumentDigests.self, from: data)
        
        XCTAssertEqual(response.hashes.count, 1)
        XCTAssertEqual(response.hashes[0], "lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D")
    }
    
    func testDocumentDigestsJSONEncoding() throws {
        let response = DocumentDigests(hashes: ["hash1", "hash2"])
        let data = try JSONEncoder().encode(response)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertNotNil(json["hashes"])
        let hashes = json["hashes"] as! [String]
        XCTAssertEqual(hashes.count, 2)
        XCTAssertEqual(hashes[0], "hash1")
        XCTAssertEqual(hashes[1], "hash2")
    }
    
    func testDocumentDigestsMultipleHashes() throws {
        let data = TestConstants.multipleHashesDocumentDigestsResponse.data(using: .utf8)!
        let response = try JSONDecoder().decode(DocumentDigests.self, from: data)
        
        XCTAssertEqual(response.hashes.count, 3)
        XCTAssertEqual(response.hashes[0], "hash1EncodedValue")
        XCTAssertEqual(response.hashes[1], "hash2EncodedValue")
        XCTAssertEqual(response.hashes[2], "hash3EncodedValue")
    }
    
    func testDocumentDigestsEmptyHashes() throws {
        let data = TestConstants.emptyHashesDocumentDigestsResponse.data(using: .utf8)!
        let response = try JSONDecoder().decode(DocumentDigests.self, from: data)
        
        XCTAssertEqual(response.hashes.count, 0)
    }
    
    func testDocumentDigestsInitializer() {
        let hashes = ["hash1", "hash2", "hash3"]
        let response = DocumentDigests(hashes: hashes)
        
        XCTAssertEqual(response.hashes.count, 3)
        XCTAssertEqual(response.hashes, hashes)
    }

    func testCalculateHashErrorCases() {
        let missingDocuments = CalculateHashError.missingDocuments
        let invalidDocument = CalculateHashError.invalidDocument
        let missingEndEntityCertificate = CalculateHashError.missingEndEntityCertificate
        let missingCertificateChain = CalculateHashError.missingCertificateChain
        let missingHashAlgorithmID = CalculateHashError.missingHashAlgorithmID
        let missingTsaURL = CalculateHashError.missingTsaURL(conformanceLevel: "ADES_B_LT")
        let hashCalculationError = CalculateHashError.hashCalculationError(documentPath: "/path/to/doc.pdf")

        XCTAssertNotNil(missingDocuments)
        XCTAssertNotNil(invalidDocument)
        XCTAssertNotNil(missingEndEntityCertificate)
        XCTAssertNotNil(missingCertificateChain)
        XCTAssertNotNil(missingHashAlgorithmID)
        XCTAssertNotNil(missingTsaURL)
        XCTAssertNotNil(hashCalculationError)
    }
    
    func testCalculateHashErrorLocalizedDescription() {
        let missingTsaError = CalculateHashError.missingTsaURL(conformanceLevel: "ADES_B_LT")
        XCTAssertEqual(missingTsaError.errorDescription, "For conformance level “ADES_B_LT” you must provide a TSR_URL.")

        XCTAssertNil(CalculateHashError.missingDocuments.errorDescription)
        XCTAssertNil(CalculateHashError.invalidDocument.errorDescription)
        XCTAssertNil(CalculateHashError.missingEndEntityCertificate.errorDescription)
        XCTAssertNil(CalculateHashError.missingCertificateChain.errorDescription)
        XCTAssertNil(CalculateHashError.missingHashAlgorithmID.errorDescription)
        XCTAssertNil(CalculateHashError.hashCalculationError(documentPath: "test.pdf").errorDescription)
    }

    func testValidateValidRequest() throws {
        let request = TestConstants.standardCalculateHashRequest
        try CalculateHashValidator.validate(request: request)
    }
    
    func testValidateMinimalValidRequest() throws {
        let request = TestConstants.minimalCalculateHashRequestObject
        try CalculateHashValidator.validate(request: request)
    }
    
    func testValidateEmptyDocuments() {
        let request = CalculateHashRequest(
            documents: [],
            endEntityCertificate: "CERT",
            certificateChain: ["CHAIN"],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
        )
        
        XCTAssertThrowsError(try CalculateHashValidator.validate(request: request)) { error in
            guard case .missingDocuments = error as? CalculateHashError else {
                return XCTFail("Expected .missingDocuments, but got \(error)")
            }
        }
    }
    
    func testValidateInvalidDocument() {
        let invalidDocument = CalculateHashRequest.Document(
            documentInputPath: "",
            documentOutputPath: "output.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let request = CalculateHashRequest(
            documents: [invalidDocument],
            endEntityCertificate: "CERT",
            certificateChain: ["CHAIN"],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
        )
        
        XCTAssertThrowsError(try CalculateHashValidator.validate(request: request)) { error in
            guard case .invalidDocument = error as? CalculateHashError else {
                return XCTFail("Expected .invalidDocument, but got \(error)")
            }
        }
    }
    
    func testValidateMissingEndEntityCertificate() {
        let document = CalculateHashRequest.Document(
            documentInputPath: "input.pdf",
            documentOutputPath: "output.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let request = CalculateHashRequest(
            documents: [document],
            endEntityCertificate: "",
            certificateChain: ["CHAIN"],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
        )
        
        XCTAssertThrowsError(try CalculateHashValidator.validate(request: request)) { error in
            guard case .missingEndEntityCertificate = error as? CalculateHashError else {
                return XCTFail("Expected .missingEndEntityCertificate, but got \(error)")
            }
        }
    }
    
    func testValidateMissingCertificateChain() {
        let document = CalculateHashRequest.Document(
            documentInputPath: "input.pdf",
            documentOutputPath: "output.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let request = CalculateHashRequest(
            documents: [document],
            endEntityCertificate: "CERT",
            certificateChain: [],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
        )
        
        XCTAssertThrowsError(try CalculateHashValidator.validate(request: request)) { error in
            guard case .missingCertificateChain = error as? CalculateHashError else {
                return XCTFail("Expected .missingCertificateChain, but got \(error)")
            }
        }
    }
    
    func testValidateMultipleDocumentsWithOneInvalid() {
        let validDocument = CalculateHashRequest.Document(
            documentInputPath: "valid.pdf",
            documentOutputPath: "valid-signed.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let invalidDocument = CalculateHashRequest.Document(
            documentInputPath: "",
            documentOutputPath: "invalid-signed.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let request = CalculateHashRequest(
            documents: [validDocument, invalidDocument],
            endEntityCertificate: "CERT",
            certificateChain: ["CHAIN"],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
        )
        
        XCTAssertThrowsError(try CalculateHashValidator.validate(request: request)) { error in
            guard case .invalidDocument = error as? CalculateHashError else {
                return XCTFail("Expected .invalidDocument, but got \(error)")
            }
        }
    }
    
    func testValidateComplexValidRequest() throws {
        let document1 = CalculateHashRequest.Document(
            documentInputPath: "document1.pdf",
            documentOutputPath: "document1-signed.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
        
        let document2 = CalculateHashRequest.Document(
            documentInputPath: "document2.pdf",
            documentOutputPath: "document2-signed.pdf",
            signatureFormat: SignatureFormat.C,
            conformanceLevel: ConformanceLevel.ADES_B_LT,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPING,
            container: "ASiC-S"
        )
        
        let request = CalculateHashRequest(
            documents: [document1, document2],
            endEntityCertificate: "LONG_CERTIFICATE_STRING",
            certificateChain: ["CERT1", "CERT2", "ROOT_CERT"],
            hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.3")
        )

        try CalculateHashValidator.validate(request: request)
    }
} 
 
