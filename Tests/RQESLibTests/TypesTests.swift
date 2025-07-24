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

class TypesTests: XCTestCase {

    func testASICContainerStaticConstants() {
        XCTAssertEqual(ASICContainer.NONE.rawValue, "NONE")
        XCTAssertEqual(ASICContainer.ASIC_S.rawValue, "ASIC_S")
        XCTAssertEqual(ASICContainer.ASIC_E.rawValue, "ASIC_E")
    }

    func testASICContainerInitializers() {
        let container1 = ASICContainer(rawValue: "CUSTOM")
        XCTAssertEqual(container1.rawValue, "CUSTOM")
        
        let container2 = ASICContainer("ANOTHER")
        XCTAssertEqual(container2.rawValue, "ANOTHER")
        
        let container3: ASICContainer = "STRING_LITERAL"
        XCTAssertEqual(container3.rawValue, "STRING_LITERAL")
    }

    func testASICContainerDescription() {
        let container = ASICContainer.ASIC_S
        XCTAssertEqual(container.description, "ASIC_S")
        XCTAssertEqual("\(container)", "ASIC_S")
    }

    func testConformanceLevelStaticConstants() {
        XCTAssertEqual(ConformanceLevel.ADES_B_B.rawValue, "ADES_B_B")
        XCTAssertEqual(ConformanceLevel.ADES_B_T.rawValue, "ADES_B_T")
        XCTAssertEqual(ConformanceLevel.ADES_B_LT.rawValue, "ADES_B_LT")
        XCTAssertEqual(ConformanceLevel.ADES_B_LTA.rawValue, "ADES_B_LTA")
    }

    func testConformanceLevelInitializers() {
        let level1 = ConformanceLevel(rawValue: "CUSTOM_LEVEL")
        XCTAssertEqual(level1.rawValue, "CUSTOM_LEVEL")
        
        let level2 = ConformanceLevel("ANOTHER_LEVEL")
        XCTAssertEqual(level2.rawValue, "ANOTHER_LEVEL")
        
        let level3: ConformanceLevel = "STRING_LITERAL_LEVEL"
        XCTAssertEqual(level3.rawValue, "STRING_LITERAL_LEVEL")
    }

    func testConformanceLevelDescription() {
        let level = ConformanceLevel.ADES_B_LT
        XCTAssertEqual(level.description, "ADES_B_LT")
        XCTAssertEqual("\(level)", "ADES_B_LT")
    }

    func testConformanceLevelCodable() throws {
        let originalLevel = ConformanceLevel.ADES_B_T
        let jsonData = try JSONEncoder().encode(originalLevel)
        let decodedLevel = try JSONDecoder().decode(ConformanceLevel.self, from: jsonData)
        
        XCTAssertEqual(decodedLevel.rawValue, originalLevel.rawValue)
    }

    func testHashAlgorithmOIDStaticConstants() {
        XCTAssertEqual(HashAlgorithmOID.SHA224.rawValue, "2.16.840.1.101.3.4.2.4")
        XCTAssertEqual(HashAlgorithmOID.SHA256.rawValue, "2.16.840.1.101.3.4.2.1")
        XCTAssertEqual(HashAlgorithmOID.SHA385.rawValue, "2.16.840.1.101.3.4.2.2")
        XCTAssertEqual(HashAlgorithmOID.SHA512.rawValue, "2.16.840.1.101.3.4.2.3")
        XCTAssertEqual(HashAlgorithmOID.SHA3_224.rawValue, "2.16.840.1.101.3.4.2.7")
        XCTAssertEqual(HashAlgorithmOID.SHA3_256.rawValue, "2.16.840.1.101.3.4.2.8")
        XCTAssertEqual(HashAlgorithmOID.SHA3_385.rawValue, "2.16.840.1.101.3.4.2.9")
        XCTAssertEqual(HashAlgorithmOID.SHA3_512.rawValue, "2.16.840.1.101.3.4.2.10")
        XCTAssertEqual(HashAlgorithmOID.MD2.rawValue, "1.2.840.113549.2.2")
        XCTAssertEqual(HashAlgorithmOID.MD5.rawValue, "1.2.840.113549.2.5")
    }

    func testHashAlgorithmOIDInitializers() {
        let oid1 = HashAlgorithmOID(rawValue: "1.2.3.4.5")
        XCTAssertEqual(oid1.rawValue, "1.2.3.4.5")
        
        let oid2 = HashAlgorithmOID("2.3.4.5.6")
        XCTAssertEqual(oid2.rawValue, "2.3.4.5.6")
        
        let oid3: HashAlgorithmOID = "3.4.5.6.7"
        XCTAssertEqual(oid3.rawValue, "3.4.5.6.7")
    }

    func testHashAlgorithmOIDDescription() {
        let oid = HashAlgorithmOID.SHA256
        XCTAssertEqual(oid.description, "2.16.840.1.101.3.4.2.1")
        XCTAssertEqual("\(oid)", "2.16.840.1.101.3.4.2.1")
    }

    func testSignatureFormatStaticConstants() {
        XCTAssertEqual(SignatureFormat.C.rawValue, "C")
        XCTAssertEqual(SignatureFormat.X.rawValue, "X")
        XCTAssertEqual(SignatureFormat.P.rawValue, "P")
        XCTAssertEqual(SignatureFormat.J.rawValue, "J")
    }

    func testSignatureFormatInitializers() {
        let format1 = SignatureFormat(rawValue: "CUSTOM")
        XCTAssertEqual(format1.rawValue, "CUSTOM")
        
        let format2 = SignatureFormat("ANOTHER")
        XCTAssertEqual(format2.rawValue, "ANOTHER")
        
        let format3: SignatureFormat = "LITERAL"
        XCTAssertEqual(format3.rawValue, "LITERAL")
    }

    func testSignatureFormatDescription() {
        let format = SignatureFormat.P
        XCTAssertEqual(format.description, "P")
        XCTAssertEqual("\(format)", "P")
    }

    func testSignatureFormatCodable() throws {
        let originalFormat = SignatureFormat.X
        let jsonData = try JSONEncoder().encode(originalFormat)
        let decodedFormat = try JSONDecoder().decode(SignatureFormat.self, from: jsonData)
        
        XCTAssertEqual(decodedFormat.rawValue, originalFormat.rawValue)
    }

    func testSignatureQualifierStaticConstants() {
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_QES.rawValue, "eu_eidas_qes")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AES.rawValue, "eu_eidas_aes")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AESQC.rawValue, "eu_eidas_aesqc")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_QESEAL.rawValue, "eu_eidas_qeseal")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AESEAL.rawValue, "eu_eidas_aeseal")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AESEALQC.rawValue, "eu_eidas_aesealqc")
        XCTAssertEqual(SignatureQualifier.ZA_ECTA_AES.rawValue, "za_ecta_aes")
        XCTAssertEqual(SignatureQualifier.ZA_ECTA_OES.rawValue, "za_ecta_oes")
    }

    func testSignatureQualifierInitializers() {
        let qualifier1 = SignatureQualifier(rawValue: "custom_qualifier")
        XCTAssertEqual(qualifier1.rawValue, "custom_qualifier")
        
        let qualifier2 = SignatureQualifier("another_qualifier")
        XCTAssertEqual(qualifier2.rawValue, "another_qualifier")
        
        let qualifier3: SignatureQualifier = "literal_qualifier"
        XCTAssertEqual(qualifier3.rawValue, "literal_qualifier")
    }

    func testSignatureQualifierDescription() {
        let qualifier = SignatureQualifier.EU_EIDAS_QES
        XCTAssertEqual(qualifier.description, "eu_eidas_qes")
        XCTAssertEqual("\(qualifier)", "eu_eidas_qes")
    }

    func testSignatureQualifierCodable() throws {
        let originalQualifier = SignatureQualifier.EU_EIDAS_AESEAL
        let jsonData = try JSONEncoder().encode(originalQualifier)
        let decodedQualifier = try JSONDecoder().decode(SignatureQualifier.self, from: jsonData)
        
        XCTAssertEqual(decodedQualifier.rawValue, originalQualifier.rawValue)
    }

    func testSignedEnvelopePropertyStaticConstants() {
        XCTAssertEqual(SignedEnvelopeProperty.ENVELOPED.rawValue, "ENVELOPED")
        XCTAssertEqual(SignedEnvelopeProperty.ENVELOPING.rawValue, "ENVELOPING")
        XCTAssertEqual(SignedEnvelopeProperty.DETACHED.rawValue, "DETACHED")
        XCTAssertEqual(SignedEnvelopeProperty.INTERNALLY_DETACHED.rawValue, "INTERNALLY_DETACHED")
    }

    func testSignedEnvelopePropertyInitializers() {
        let property1 = SignedEnvelopeProperty(rawValue: "CUSTOM_PROPERTY")
        XCTAssertEqual(property1.rawValue, "CUSTOM_PROPERTY")
        
        let property2 = SignedEnvelopeProperty("ANOTHER_PROPERTY")
        XCTAssertEqual(property2.rawValue, "ANOTHER_PROPERTY")
        
        let property3: SignedEnvelopeProperty = "LITERAL_PROPERTY"
        XCTAssertEqual(property3.rawValue, "LITERAL_PROPERTY")
    }

    func testSignedEnvelopePropertyDescription() {
        let property = SignedEnvelopeProperty.INTERNALLY_DETACHED
        XCTAssertEqual(property.description, "INTERNALLY_DETACHED")
        XCTAssertEqual("\(property)", "INTERNALLY_DETACHED")
    }

    func testSignedEnvelopePropertyCodable() throws {
        let originalProperty = SignedEnvelopeProperty.ENVELOPING
        let jsonData = try JSONEncoder().encode(originalProperty)
        let decodedProperty = try JSONDecoder().decode(SignedEnvelopeProperty.self, from: jsonData)
        
        XCTAssertEqual(decodedProperty.rawValue, originalProperty.rawValue)
    }

    func testSigningAlgorithmOIDStaticConstants() {
        XCTAssertEqual(SigningAlgorithmOID.RSA.rawValue, "1.2.840.113549.1.1.1")
        XCTAssertEqual(SigningAlgorithmOID.SHA256WithRSA.rawValue, "1.2.840.113549.1.1.11")
        XCTAssertEqual(SigningAlgorithmOID.SHA384WithRSA.rawValue, "1.2.840.113549.1.1.12")
        XCTAssertEqual(SigningAlgorithmOID.SHA512WithRSA.rawValue, "1.2.840.113549.1.1.13")
        XCTAssertEqual(SigningAlgorithmOID.ECDSA.rawValue, "1.2.840.10045.2.1")
        XCTAssertEqual(SigningAlgorithmOID.SHA256WithECDSA.rawValue, "1.2.840.10045.4.3.2")
        XCTAssertEqual(SigningAlgorithmOID.SHA384WithECDSA.rawValue, "1.2.840.10045.4.3.3")
        XCTAssertEqual(SigningAlgorithmOID.SHA512WithECDSA.rawValue, "1.2.840.10045.4.3.4")
        XCTAssertEqual(SigningAlgorithmOID.DSA.rawValue, "1.2.840.10040.4.1")
        XCTAssertEqual(SigningAlgorithmOID.X25519.rawValue, "1.3.101.110")
        XCTAssertEqual(SigningAlgorithmOID.X448.rawValue, "1.3.101.111")
    }

    func testSigningAlgorithmOIDInitializers() {
        let oid1 = SigningAlgorithmOID(rawValue: "1.2.3.4.5")
        XCTAssertEqual(oid1.rawValue, "1.2.3.4.5")
        
        let oid2 = SigningAlgorithmOID("2.3.4.5.6")
        XCTAssertEqual(oid2.rawValue, "2.3.4.5.6")
        
        let oid3: SigningAlgorithmOID = "3.4.5.6.7"
        XCTAssertEqual(oid3.rawValue, "3.4.5.6.7")
    }

    func testSigningAlgorithmOIDDescription() {
        let oid = SigningAlgorithmOID.ECDSA
        XCTAssertEqual(oid.description, "1.2.840.10045.2.1")
        XCTAssertEqual("\(oid)", "1.2.840.10045.2.1")
    }

    func testSigningAlgorithmOIDCodable() throws {
        let originalOID = SigningAlgorithmOID.SHA256WithECDSA
        let jsonData = try JSONEncoder().encode(originalOID)
        let decodedOID = try JSONDecoder().decode(SigningAlgorithmOID.self, from: jsonData)
        
        XCTAssertEqual(decodedOID.rawValue, originalOID.rawValue)
    }

    func testAllTypesImplementRequiredProtocols() {
        XCTAssertFalse(ASICContainer.NONE.rawValue.isEmpty)
        XCTAssertFalse(ConformanceLevel.ADES_B_B.rawValue.isEmpty)
        XCTAssertFalse(HashAlgorithmOID.SHA256.rawValue.isEmpty)
        XCTAssertFalse(SignatureFormat.C.rawValue.isEmpty)
        XCTAssertFalse(SignatureQualifier.EU_EIDAS_QES.rawValue.isEmpty)
        XCTAssertFalse(SignedEnvelopeProperty.ENVELOPED.rawValue.isEmpty)
        XCTAssertFalse(SigningAlgorithmOID.RSA.rawValue.isEmpty)

        XCTAssertFalse(ASICContainer.ASIC_S.description.isEmpty)
        XCTAssertFalse(ConformanceLevel.ADES_B_T.description.isEmpty)
        XCTAssertFalse(HashAlgorithmOID.SHA512.description.isEmpty)
        XCTAssertFalse(SignatureFormat.P.description.isEmpty)
        XCTAssertFalse(SignatureQualifier.EU_EIDAS_AES.description.isEmpty)
        XCTAssertFalse(SignedEnvelopeProperty.DETACHED.description.isEmpty)
        XCTAssertFalse(SigningAlgorithmOID.ECDSA.description.isEmpty)
    }

    func testStringLiteralConformance() {
        let container: ASICContainer = "TEST_CONTAINER"
        let level: ConformanceLevel = "TEST_LEVEL"
        let hashOID: HashAlgorithmOID = "1.2.3.4.5"
        let format: SignatureFormat = "TEST_FORMAT"
        let qualifier: SignatureQualifier = "test_qualifier"
        let property: SignedEnvelopeProperty = "TEST_PROPERTY"
        let signingOID: SigningAlgorithmOID = "1.2.3.4.5"
        
        XCTAssertEqual(container.rawValue, "TEST_CONTAINER")
        XCTAssertEqual(level.rawValue, "TEST_LEVEL")
        XCTAssertEqual(hashOID.rawValue, "1.2.3.4.5")
        XCTAssertEqual(format.rawValue, "TEST_FORMAT")
        XCTAssertEqual(qualifier.rawValue, "test_qualifier")
        XCTAssertEqual(property.rawValue, "TEST_PROPERTY")
        XCTAssertEqual(signingOID.rawValue, "1.2.3.4.5")
    }

    func testJSONEncodingDecoding() throws {
        let testData: [(String, any Codable)] = [
            ("ASICContainer", ASICContainer.ASIC_E),
            ("ConformanceLevel", ConformanceLevel.ADES_B_LTA),
            ("HashAlgorithmOID", HashAlgorithmOID.SHA3_256),
            ("SignatureFormat", SignatureFormat.J),
            ("SignatureQualifier", SignatureQualifier.EU_EIDAS_QESEAL),
            ("SignedEnvelopeProperty", SignedEnvelopeProperty.INTERNALLY_DETACHED),
            ("SigningAlgorithmOID", SigningAlgorithmOID.SHA384WithECDSA)
        ]
        
        for (typeName, value) in testData {
            let jsonData = try JSONEncoder().encode(value)
            XCTAssertFalse(jsonData.isEmpty, "\(typeName) should encode to non-empty JSON")

            let jsonString = String(data: jsonData, encoding: .utf8)
            XCTAssertNotNil(jsonString, "\(typeName) should produce valid UTF-8 JSON")
            XCTAssertTrue(jsonString?.contains("\"") == true, "\(typeName) JSON should contain quotes")
        }
    }
} 
