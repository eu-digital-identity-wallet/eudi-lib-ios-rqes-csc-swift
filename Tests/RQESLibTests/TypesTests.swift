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

    func testASICContainerCodable() throws {
        let original = ASICContainer.ASIC_E
        let jsonData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ASICContainer.self, from: jsonData)
        XCTAssertEqual(decoded, original)
    }

    func testConformanceLevelStaticConstants() {
        XCTAssertEqual(ConformanceLevel.ADES_B_B.rawValue, "ADES_B_B")
        XCTAssertEqual(ConformanceLevel.ADES_B_T.rawValue, "ADES_B_T")
        XCTAssertEqual(ConformanceLevel.ADES_B_LT.rawValue, "ADES_B_LT")
        XCTAssertEqual(ConformanceLevel.ADES_B_LTA.rawValue, "ADES_B_LTA")
    }

    func testConformanceLevelCodable() throws {
        let originalLevel = ConformanceLevel.ADES_B_T
        let jsonData = try JSONEncoder().encode(originalLevel)
        let decodedLevel = try JSONDecoder().decode(ConformanceLevel.self, from: jsonData)
        
        XCTAssertEqual(decodedLevel, originalLevel)
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

    func testHashAlgorithmOIDCodable() throws {
        let original = HashAlgorithmOID.SHA256
        let jsonData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HashAlgorithmOID.self, from: jsonData)
        XCTAssertEqual(decoded, original)
    }

    func testSignatureFormatStaticConstants() {
        XCTAssertEqual(SignatureFormat.C.rawValue, "C")
        XCTAssertEqual(SignatureFormat.X.rawValue, "X")
        XCTAssertEqual(SignatureFormat.P.rawValue, "P")
        XCTAssertEqual(SignatureFormat.J.rawValue, "J")
    }

    func testSignatureFormatCodable() throws {
        let originalFormat = SignatureFormat.X
        let jsonData = try JSONEncoder().encode(originalFormat)
        let decodedFormat = try JSONDecoder().decode(SignatureFormat.self, from: jsonData)
        
        XCTAssertEqual(decodedFormat, originalFormat)
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

    func testSignatureQualifierCodable() throws {
        let originalQualifier = SignatureQualifier.EU_EIDAS_AESEAL
        let jsonData = try JSONEncoder().encode(originalQualifier)
        let decodedQualifier = try JSONDecoder().decode(SignatureQualifier.self, from: jsonData)
        
        XCTAssertEqual(decodedQualifier, originalQualifier)
    }

    func testSignedEnvelopePropertyStaticConstants() {
        XCTAssertEqual(SignedEnvelopeProperty.ENVELOPED.rawValue, "ENVELOPED")
        XCTAssertEqual(SignedEnvelopeProperty.ENVELOPING.rawValue, "ENVELOPING")
        XCTAssertEqual(SignedEnvelopeProperty.DETACHED.rawValue, "DETACHED")
        XCTAssertEqual(SignedEnvelopeProperty.INTERNALLY_DETACHED.rawValue, "INTERNALLY_DETACHED")
    }

    func testSignedEnvelopePropertyCodable() throws {
        let originalProperty = SignedEnvelopeProperty.ENVELOPING
        let jsonData = try JSONEncoder().encode(originalProperty)
        let decodedProperty = try JSONDecoder().decode(SignedEnvelopeProperty.self, from: jsonData)
        
        XCTAssertEqual(decodedProperty, originalProperty)
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

    func testSigningAlgorithmOIDCodable() throws {
        let originalOID = SigningAlgorithmOID.SHA256WithECDSA
        let jsonData = try JSONEncoder().encode(originalOID)
        let decodedOID = try JSONDecoder().decode(SigningAlgorithmOID.self, from: jsonData)
        
        XCTAssertEqual(decodedOID, originalOID)
    }

    func testScopeStaticConstants() {
        XCTAssertEqual(Scope.SERVICE.rawValue, "service")
        XCTAssertEqual(Scope.CREDENTIAL.rawValue, "credential")
    }

    func testScopeCodable() throws {
        let original = Scope.CREDENTIAL
        let jsonData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Scope.self, from: jsonData)
        XCTAssertEqual(decoded, original)
    }

    func testAllTypesImplementRequiredProtocols() {
        XCTAssertFalse(ASICContainer.NONE.rawValue.isEmpty)
        XCTAssertFalse(ConformanceLevel.ADES_B_B.rawValue.isEmpty)
        XCTAssertFalse(HashAlgorithmOID.SHA256.rawValue.isEmpty)
        XCTAssertFalse(SignatureFormat.C.rawValue.isEmpty)
        XCTAssertFalse(SignatureQualifier.EU_EIDAS_QES.rawValue.isEmpty)
        XCTAssertFalse(SignedEnvelopeProperty.ENVELOPED.rawValue.isEmpty)
        XCTAssertFalse(SigningAlgorithmOID.RSA.rawValue.isEmpty)
        XCTAssertFalse(Scope.SERVICE.rawValue.isEmpty)

        XCTAssertFalse(ASICContainer.ASIC_S.description.isEmpty)
        XCTAssertFalse(ConformanceLevel.ADES_B_T.description.isEmpty)
        XCTAssertFalse(HashAlgorithmOID.SHA512.description.isEmpty)
        XCTAssertFalse(SignatureFormat.P.description.isEmpty)
        XCTAssertFalse(SignatureQualifier.EU_EIDAS_AES.description.isEmpty)
        XCTAssertFalse(SignedEnvelopeProperty.DETACHED.description.isEmpty)
        XCTAssertFalse(SigningAlgorithmOID.ECDSA.description.isEmpty)
        XCTAssertFalse(Scope.CREDENTIAL.description.isEmpty)
    }

    func testJSONEncodingDecoding() throws {
        let testData: [(String, any Codable & RawRepresentable)] = [
            ("ASICContainer", ASICContainer.ASIC_E),
            ("ConformanceLevel", ConformanceLevel.ADES_B_LTA),
            ("HashAlgorithmOID", HashAlgorithmOID.SHA3_256),
            ("SignatureFormat", SignatureFormat.J),
            ("SignatureQualifier", SignatureQualifier.EU_EIDAS_QESEAL),
            ("SignedEnvelopeProperty", SignedEnvelopeProperty.INTERNALLY_DETACHED),
            ("SigningAlgorithmOID", SigningAlgorithmOID.SHA384WithECDSA),
            ("Scope", Scope.SERVICE)
        ]
        
        for (typeName, value) in testData {
            let jsonData = try JSONEncoder().encode(value)
            XCTAssertFalse(jsonData.isEmpty, "\(typeName) should encode to non-empty JSON")

            let jsonString = String(data: jsonData, encoding: .utf8)
            XCTAssertNotNil(jsonString, "\(typeName) should produce valid UTF-8 JSON")
            
            if let rawValue = value.rawValue as? String {
                let expectedJsonString = "\"\(rawValue)\""
                XCTAssertEqual(jsonString, expectedJsonString, "JSON string for \(typeName) is incorrect")
            } else {
                XCTFail("Could not get rawValue as String for \(typeName)")
            }
        }
    }

    func testRawValueInitializers() {
        let testStrings = ["", "123-ABC", "!@#$%^&*()", "a long string with spaces"]

        for testString in testStrings {
            let container = ASICContainer(rawValue: testString)
            XCTAssertEqual(container.rawValue, testString)

            let level = ConformanceLevel(rawValue: testString)
            XCTAssertEqual(level.rawValue, testString)

            let hashOid = HashAlgorithmOID(rawValue: testString)
            XCTAssertEqual(hashOid.rawValue, testString)

            let format = SignatureFormat(rawValue: testString)
            XCTAssertEqual(format.rawValue, testString)

            let qualifier = SignatureQualifier(rawValue: testString)
            XCTAssertEqual(qualifier.rawValue, testString)

            let property = SignedEnvelopeProperty(rawValue: testString)
            XCTAssertEqual(property.rawValue, testString)

            let signingOid = SigningAlgorithmOID(rawValue: testString)
            XCTAssertEqual(signingOid.rawValue, testString)
        }
    }

    func testConvenienceInitializersAndDescription() {
        let testValue = "TEST"

        let containerFromValue = ASICContainer(testValue)
        XCTAssertEqual(containerFromValue.rawValue, testValue)
        let containerFromStringLiteral: ASICContainer = "TEST"
        XCTAssertEqual(containerFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(containerFromValue.description, testValue)
        XCTAssertEqual("\(containerFromValue)", testValue)

        let levelFromValue = ConformanceLevel(testValue)
        XCTAssertEqual(levelFromValue.rawValue, testValue)
        let levelFromStringLiteral: ConformanceLevel = "TEST"
        XCTAssertEqual(levelFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(levelFromValue.description, testValue)
        XCTAssertEqual("\(levelFromValue)", testValue)

        let hashFromValue = HashAlgorithmOID(testValue)
        XCTAssertEqual(hashFromValue.rawValue, testValue)
        let hashFromStringLiteral: HashAlgorithmOID = "TEST"
        XCTAssertEqual(hashFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(hashFromValue.description, testValue)
        XCTAssertEqual("\(hashFromValue)", testValue)

        let formatFromValue = SignatureFormat(testValue)
        XCTAssertEqual(formatFromValue.rawValue, testValue)
        let formatFromStringLiteral: SignatureFormat = "TEST"
        XCTAssertEqual(formatFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(formatFromValue.description, testValue)
        XCTAssertEqual("\(formatFromValue)", testValue)

        let qualifierFromValue = SignatureQualifier(testValue)
        XCTAssertEqual(qualifierFromValue.rawValue, testValue)
        let qualifierFromStringLiteral: SignatureQualifier = "TEST"
        XCTAssertEqual(qualifierFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(qualifierFromValue.description, testValue)
        XCTAssertEqual("\(qualifierFromValue)", testValue)

        let propertyFromValue = SignedEnvelopeProperty(testValue)
        XCTAssertEqual(propertyFromValue.rawValue, testValue)
        let propertyFromStringLiteral: SignedEnvelopeProperty = "TEST"
        XCTAssertEqual(propertyFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(propertyFromValue.description, testValue)
        XCTAssertEqual("\(propertyFromValue)", testValue)

        let signingOidFromValue = SigningAlgorithmOID(testValue)
        XCTAssertEqual(signingOidFromValue.rawValue, testValue)
        let signingOidFromStringLiteral: SigningAlgorithmOID = "TEST"
        XCTAssertEqual(signingOidFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(signingOidFromValue.description, testValue)
        XCTAssertEqual("\(signingOidFromValue)", testValue)

        let scopeFromValue = Scope(testValue)
        XCTAssertEqual(scopeFromValue.rawValue, testValue)
        let scopeFromStringLiteral: Scope = "TEST"
        XCTAssertEqual(scopeFromStringLiteral.rawValue, testValue)
        XCTAssertEqual(scopeFromValue.description, testValue)
        XCTAssertEqual("\(scopeFromValue)", testValue)
    }

    func testHashableConformance() {
        let containerSet: Set<ASICContainer> = [.NONE, .ASIC_S, .ASIC_E, .NONE]
        XCTAssertEqual(containerSet.count, 3)

        let levelSet: Set<ConformanceLevel> = [.ADES_B_B, .ADES_B_T, .ADES_B_LT, .ADES_B_LTA, .ADES_B_T]
        XCTAssertEqual(levelSet.count, 4)

        var hashOidSet: Set<HashAlgorithmOID> = [.SHA256, .SHA512]
        hashOidSet.insert(.SHA256)
        XCTAssertEqual(hashOidSet.count, 2)

        let formatSet: Set<SignatureFormat> = [.P, .X, .C, .J, .P]
        XCTAssertEqual(formatSet.count, 4)

        let qualifierSet: Set<SignatureQualifier> = [.EU_EIDAS_QES, .EU_EIDAS_AES, .EU_EIDAS_QES]
        XCTAssertEqual(qualifierSet.count, 2)

        let propertySet: Set<SignedEnvelopeProperty> = [.ENVELOPED, .DETACHED, .ENVELOPED]
        XCTAssertEqual(propertySet.count, 2)

        var signingOidSet: Set<SigningAlgorithmOID> = [.RSA, .ECDSA]
        signingOidSet.insert(.RSA)
        XCTAssertEqual(signingOidSet.count, 2)

        let scopeSet: Set<Scope> = [.SERVICE, .CREDENTIAL, .SERVICE]
        XCTAssertEqual(scopeSet.count, 2)
    }
} 
