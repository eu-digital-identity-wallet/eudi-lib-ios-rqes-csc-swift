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
import Foundation
import PoDoFo
@testable import RQESLib

class PodofoSessionTests: XCTestCase {

    var inputPath: String!
    var outputPath: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let tempDir = NSTemporaryDirectory()
        inputPath = "\(tempDir)/input.pdf"
        outputPath = "\(tempDir)/output.pdf"

        FileManager.default.createFile(atPath: inputPath, contents: Data("dummy content".utf8), attributes: nil)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(atPath: inputPath)
        try? FileManager.default.removeItem(atPath: outputPath)
        inputPath = nil
        outputPath = nil
        try super.tearDownWithError()
    }

    func testInitialization_AssignsPropertiesCorrectly() {
        let podofoWrapper = PodofoWrapper(
            conformanceLevel: ConformanceLevel.ADES_B_B.rawValue,
            hashAlgorithm: HashAlgorithmOID.SHA256.rawValue,
            inputPath: inputPath,
            outputPath: outputPath,
            certificate: "endCertificateData",
            chainCertificates: ["chainCert1", "chainCert2"]
        )
        
        let sessionId = UUID().uuidString
        let conformance = ConformanceLevel.ADES_B_LT
        let endCert = "testEndCertificate"
        let chainCerts = ["chain1", "chain2", "chain3"]

        let podofoSession = PodofoSession(
            id: sessionId,
            session: podofoWrapper,
            conformanceLevel: conformance,
            endCertificate: endCert,
            chainCertificates: chainCerts
        )

        XCTAssertEqual(podofoSession.id, sessionId)
        XCTAssertEqual(podofoSession.conformanceLevel.rawValue, conformance.rawValue)
        XCTAssertEqual(podofoSession.endCertificate, endCert)
        XCTAssertEqual(podofoSession.chainCertificates, chainCerts)

        XCTAssertTrue(podofoSession.session === podofoWrapper)

        XCTAssertNil(podofoSession.tsrLT)
        XCTAssertNil(podofoSession.tsrLTA)
        XCTAssertTrue(podofoSession.crlUrls.isEmpty)
        XCTAssertTrue(podofoSession.ocspUrls.isEmpty)
    }
    
    func testInitialization_WithDefaultChainCertificates() {
        let podofoWrapper = PodofoWrapper(
            conformanceLevel: ConformanceLevel.ADES_B_B.rawValue,
            hashAlgorithm: HashAlgorithmOID.SHA256.rawValue,
            inputPath: inputPath,
            outputPath: outputPath,
            certificate: "endCertificateData",
            chainCertificates: []
        )
        
        let sessionId = UUID().uuidString
        let conformance = ConformanceLevel.ADES_B_B
        let endCert = "testEndCertificate"

        let podofoSession = PodofoSession(
            id: sessionId,
            session: podofoWrapper,
            conformanceLevel: conformance,
            endCertificate: endCert
        )

        XCTAssertEqual(podofoSession.id, sessionId)
        XCTAssertEqual(podofoSession.conformanceLevel.rawValue, conformance.rawValue)
        XCTAssertEqual(podofoSession.endCertificate, endCert)

        XCTAssertTrue(podofoSession.chainCertificates.isEmpty)
    }
} 
