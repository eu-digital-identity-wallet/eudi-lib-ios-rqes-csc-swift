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

class CredentialsInfoTests: XCTestCase {

    func testRequestJSONEncodingWithAllParameters() throws {
        let request = CredentialsInfoRequest(
            credentialID: "test-credential-123",
            certificates: "single",
            certInfo: false,
            authInfo: true,
            lang: "es-ES",
            clientData: "custom-client-data"
        )
        
        let jsonData = try JSONEncoder().encode(request)
        let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        XCTAssertNotNil(jsonDict, "Should produce valid JSON")
        XCTAssertEqual(jsonDict?["credentialID"] as? String, "test-credential-123")
        XCTAssertEqual(jsonDict?["certificates"] as? String, "single")
        XCTAssertEqual(jsonDict?["certInfo"] as? Bool, false)
        XCTAssertEqual(jsonDict?["auth_info"] as? Bool, true)
        XCTAssertEqual(jsonDict?["lang"] as? String, "es-ES")
        XCTAssertEqual(jsonDict?["client_data"] as? String, "custom-client-data")
    }

    func testRequestJSONEncodingWithMinimalParameters() throws {
        let request = CredentialsInfoRequest(credentialID: "minimal-credential")
        
        let jsonData = try JSONEncoder().encode(request)
        let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        XCTAssertNotNil(jsonDict, "Should produce valid JSON for minimal request")

        XCTAssertEqual(jsonDict?["credentialID"] as? String, "minimal-credential")

        XCTAssertEqual(jsonDict?["certificates"] as? String, "chain", "Should include default certificates value")
        XCTAssertEqual(jsonDict?["certInfo"] as? Bool, true, "Should include default certInfo value")
        XCTAssertEqual(jsonDict?["auth_info"] as? Bool, true, "Should include default authInfo value")

        XCTAssertNil(jsonDict?["lang"], "Should not include nil lang")
        XCTAssertNil(jsonDict?["client_data"], "Should not include nil clientData")
    }

    func testRequestJSONDecodingRoundTrip() throws {
        let originalRequest = CredentialsInfoRequest(
            credentialID: "round-trip-test",
            certificates: "none",
            certInfo: false,
            authInfo: false,
            lang: "fr-FR",
            clientData: "round-trip-data"
        )
        
        let jsonData = try JSONEncoder().encode(originalRequest)
        let decodedRequest = try JSONDecoder().decode(CredentialsInfoRequest.self, from: jsonData)
        
        XCTAssertEqual(decodedRequest.credentialID, originalRequest.credentialID)
        XCTAssertEqual(decodedRequest.certificates, originalRequest.certificates)
        XCTAssertEqual(decodedRequest.certInfo, originalRequest.certInfo)
        XCTAssertEqual(decodedRequest.authInfo, originalRequest.authInfo)
        XCTAssertEqual(decodedRequest.lang, originalRequest.lang)
        XCTAssertEqual(decodedRequest.clientData, originalRequest.clientData)
    }

    func testRequestJSONDecodingWithServerResponse() throws {
        let serverJson = TestConstants.serverResponseCredentialsInfoRequest.data(using: .utf8)!
        
        let request = try JSONDecoder().decode(CredentialsInfoRequest.self, from: serverJson)
        
        XCTAssertEqual(request.credentialID, "server-credential-456")
        XCTAssertEqual(request.certificates, "chain")
        XCTAssertEqual(request.certInfo, true)
        XCTAssertEqual(request.authInfo, false)
        XCTAssertEqual(request.lang, "de-DE")
        XCTAssertEqual(request.clientData, "server-data")
    }

    func testRequestInitializerDefaultValues() {
        let request = CredentialsInfoRequest(credentialID: "test-defaults")
        
        XCTAssertEqual(request.credentialID, "test-defaults")
        XCTAssertEqual(request.certificates, "chain", "certificates should default to 'chain'")
        XCTAssertEqual(request.certInfo, true, "certInfo should default to true")
        XCTAssertEqual(request.authInfo, true, "authInfo should default to true")
        XCTAssertNil(request.lang, "lang should default to nil")
        XCTAssertNil(request.clientData, "clientData should default to nil")
    }

    func testRequestCodingKeysMapping() throws {
        let request = CredentialsInfoRequest(
            credentialID: "mapping-test",
            certificates: "chain",
            certInfo: true,
            authInfo: false,
            lang: "en-US",
            clientData: "mapping-data"
        )
        
        let jsonData = try JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        XCTAssertTrue(jsonString.contains("\"credentialID\""), "Should use credentialID key")
        XCTAssertTrue(jsonString.contains("\"certificates\""), "Should use certificates key")
        XCTAssertTrue(jsonString.contains("\"certInfo\""), "Should use certInfo key")
        XCTAssertTrue(jsonString.contains("\"auth_info\""), "Should use auth_info key mapping")
        XCTAssertTrue(jsonString.contains("\"lang\""), "Should use lang key")
        XCTAssertTrue(jsonString.contains("\"client_data\""), "Should use client_data key mapping")

        XCTAssertFalse(jsonString.contains("\"authInfo\""), "Should not use Swift property name authInfo")
        XCTAssertFalse(jsonString.contains("\"clientData\""), "Should not use Swift property name clientData")
    }

    func testRequestSpecialCharactersHandling() throws {
        let request = CredentialsInfoRequest(
            credentialID: "special-chars-@#$%^&*()",
            certificates: "chain",
            certInfo: true,
            authInfo: true,
            lang: "zh-CN",
            clientData: "data with spaces & symbols!"
        )
        
        let jsonData = try JSONEncoder().encode(request)
        let decodedRequest = try JSONDecoder().decode(CredentialsInfoRequest.self, from: jsonData)
        
        XCTAssertEqual(decodedRequest.credentialID, "special-chars-@#$%^&*()", "Should preserve special characters in credential ID")
        XCTAssertEqual(decodedRequest.clientData, "data with spaces & symbols!", "Should preserve special characters in client data")
        XCTAssertEqual(decodedRequest.lang, "zh-CN", "Should preserve language codes")
    }

    func testResponseDecodingCompleteCredentialInfo() throws {
        let jsonData = TestConstants.completeCredentialInfoResponse.data(using: .utf8)!
        
        let credentialInfo = try JSONDecoder().decode(CredentialInfo.self, from: jsonData)

        XCTAssertEqual(credentialInfo.description, "Complete test credential")
        XCTAssertEqual(credentialInfo.signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(credentialInfo.multisign, 5)
        XCTAssertEqual(credentialInfo.lang, "en-US")
        XCTAssertEqual(credentialInfo.scal, "1")

        XCTAssertEqual(credentialInfo.key.status, "enabled")
        XCTAssertEqual(credentialInfo.key.algo, ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"])
        XCTAssertEqual(credentialInfo.key.len, 256)
        XCTAssertEqual(credentialInfo.key.curve, "1.2.840.10045.3.1.7")

        XCTAssertNotNil(credentialInfo.cert, "Certificate info should be present")
        XCTAssertEqual(credentialInfo.cert?.status, "valid")
        XCTAssertEqual(credentialInfo.cert?.certificates?.count, 2)
        XCTAssertEqual(credentialInfo.cert?.serialNumber, "123456789012345")
        XCTAssertEqual(credentialInfo.cert?.subjectDN, "C=US, CN=John Doe, O=Test Org")
        XCTAssertEqual(credentialInfo.cert?.issuerDN, "C=UT, O=Test CA, CN=Test Issuer")
        XCTAssertEqual(credentialInfo.cert?.validFrom, "20240101000000Z")
        XCTAssertEqual(credentialInfo.cert?.validTo, "20251231235959Z")

        XCTAssertNotNil(credentialInfo.auth, "Auth info should be present")
        XCTAssertEqual(credentialInfo.auth?.mode, "explicit")
        XCTAssertEqual(credentialInfo.auth?.expression, "PIN")
        XCTAssertEqual(credentialInfo.auth?.objects?.count, 1)

        let authObject = credentialInfo.auth?.objects?.first
        XCTAssertEqual(authObject?.type, "PIN")
        XCTAssertEqual(authObject?.id, "pin-id-1")
        XCTAssertEqual(authObject?.format, "N")
        XCTAssertEqual(authObject?.label, "Enter PIN")
        XCTAssertEqual(authObject?.description, "6-digit PIN")
    }

    func testResponseDecodingMinimalCredentialInfo() throws {
        let jsonData = TestConstants.minimalCredentialInfoResponse.data(using: .utf8)!
        
        let credentialInfo = try JSONDecoder().decode(CredentialInfo.self, from: jsonData)

        XCTAssertEqual(credentialInfo.multisign, 1)
        XCTAssertEqual(credentialInfo.key.status, "enabled")
        XCTAssertEqual(credentialInfo.key.algo, ["1.2.840.10045.2.1"])
        XCTAssertEqual(credentialInfo.key.len, 256)

        XCTAssertNil(credentialInfo.description, "description should be nil when not provided")
        XCTAssertNil(credentialInfo.signatureQualifier, "signatureQualifier should be nil when not provided")
        XCTAssertNil(credentialInfo.cert, "cert should be nil when not provided")
        XCTAssertNil(credentialInfo.auth, "auth should be nil when not provided")
        XCTAssertNil(credentialInfo.lang, "lang should be nil when not provided")
        XCTAssertNil(credentialInfo.scal, "scal should be nil when not provided")
        XCTAssertNil(credentialInfo.key.curve, "curve should be nil when not provided")
    }

    func testResponseDecodingKeyInfoVariations() throws {        
        for (keyJson, expectedAlgoCount) in TestConstants.keyVariations {
            let fullJson = """
            {
              "multisign": 1,
              "key": \(keyJson)
            }
            """.data(using: .utf8)!
            
            let credentialInfo = try JSONDecoder().decode(CredentialInfo.self, from: fullJson)
            
            XCTAssertEqual(credentialInfo.key.algo.count, expectedAlgoCount, "Should handle \(expectedAlgoCount) algorithms")
            XCTAssertNotNil(credentialInfo.key.status, "Status should always be present")
            XCTAssertGreaterThan(credentialInfo.key.len, 0, "Key length should be positive")
        }
    }

    func testResponseDecodingAuthInfoWithMultipleObjects() throws {
        let jsonData = TestConstants.multipleAuthObjectsCredentialInfoResponse.data(using: .utf8)!
        
        let credentialInfo = try JSONDecoder().decode(CredentialInfo.self, from: jsonData)
        
        XCTAssertNotNil(credentialInfo.auth, "Auth info should be present")
        XCTAssertEqual(credentialInfo.auth?.mode, "implicit")
        XCTAssertEqual(credentialInfo.auth?.expression, "PIN || BIOMETRIC")
        XCTAssertEqual(credentialInfo.auth?.objects?.count, 2)
        
        let pinObject = credentialInfo.auth?.objects?.first { $0.type == "PIN" }
        let bioObject = credentialInfo.auth?.objects?.first { $0.type == "BIOMETRIC" }
        
        XCTAssertNotNil(pinObject, "Should have PIN auth object")
        XCTAssertEqual(pinObject?.id, "pin-primary")
        XCTAssertEqual(pinObject?.format, "N")
        
        XCTAssertNotNil(bioObject, "Should have BIOMETRIC auth object")
        XCTAssertEqual(bioObject?.id, "bio-fingerprint")
        XCTAssertEqual(bioObject?.format, "B")
    }

    func testResponseDecodingSignatureQualifierVariants() throws {
        let qualifierVariants = [
            "eu_eidas_qes",
            "eu_eidas_ades", 
            "eu_eidas_qeseal",
            "eu_eidas_adeseal"
        ]
        
        for qualifier in qualifierVariants {
            let jsonString = """
            {
              "multisign" : 1,
              "signatureQualifier" : "\(qualifier)",
              "key" : {
                "status" : "enabled",
                "algo" : ["1.2.840.10045.2.1"],
                "len" : 256
              }
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            
            let credentialInfo = try JSONDecoder().decode(CredentialInfo.self, from: jsonData)
            
            XCTAssertEqual(credentialInfo.signatureQualifier?.rawValue, qualifier, "Should preserve signature qualifier: \(qualifier)")
        }
    }

    func testResponseDecodingFailsWithMissingRequiredFields() {        
        for invalidJson in TestConstants.invalidCredentialInfoJsons {
            let jsonData = invalidJson.data(using: .utf8)!
            
            XCTAssertThrowsError(try JSONDecoder().decode(CredentialInfo.self, from: jsonData)) { error in
                XCTAssertTrue(error is DecodingError, "Should throw DecodingError for missing required fields")
            }
        }
    }

    func testResponseDecodingRoundTripCompatibility() throws {
        let credentialInfoJson = TestConstants.credentialsInfoResponse
        let jsonData = credentialInfoJson.data(using: .utf8)!
        
        let credentialInfo = try JSONDecoder().decode(CredentialInfo.self, from: jsonData)

        XCTAssertNotNil(credentialInfo.description, "Should parse description from test constants")
        XCTAssertNotNil(credentialInfo.signatureQualifier, "Should parse signature qualifier from test constants")
        XCTAssertNotNil(credentialInfo.cert, "Should parse certificate from test constants")
        XCTAssertEqual(credentialInfo.key.status, "enabled", "Should parse key status from test constants")
        XCTAssertGreaterThan(credentialInfo.key.algo.count, 0, "Should parse algorithms from test constants")
    }

    func testValidatorSucceedsForValidCredentialID() throws {
        let validRequest = CredentialsInfoRequest(
            credentialID: "valid-credential-id",
            certificates: "chain",
            certInfo: true,
            authInfo: true,
            lang: nil,
            clientData: nil
        )

        XCTAssertNoThrow(try CredentialsInfoValidator.validate(validRequest), "Should accept valid credential ID")
    }

    func testValidatorFailsForEmptyCredentialID() {
        let invalidRequest = CredentialsInfoRequest(
            credentialID: "",
            certificates: "chain",
            certInfo: true,
            authInfo: true,
            lang: nil,
            clientData: nil
        )
        
        XCTAssertThrowsError(try CredentialsInfoValidator.validate(invalidRequest)) { error in
            XCTAssertEqual(error as? CredentialsInfoError, .missingCredentialID, "Should throw specific error for empty credential ID")
        }
    }

    func testValidatorSucceedsForValidCertificateTypes() throws {
        let validCertificateTypes = ["none", "single", "chain"]
        
        for certType in validCertificateTypes {
            let request = CredentialsInfoRequest(
                credentialID: "valid-id",
                certificates: certType,
                certInfo: true,
                authInfo: true,
                lang: nil,
                clientData: nil
            )
            
            XCTAssertNoThrow(try CredentialsInfoValidator.validate(request), "Should accept valid certificate type: \(certType)")
        }
    }

    func testValidatorFailsForInvalidCertificateTypes() {
        let invalidCertificateTypes = ["invalid", "all", "full", "complete", "wrong"]
        
        for invalidType in invalidCertificateTypes {
            let request = CredentialsInfoRequest(
                credentialID: "valid-id",
                certificates: invalidType,
                certInfo: true,
                authInfo: true,
                lang: nil,
                clientData: nil
            )
            
            XCTAssertThrowsError(try CredentialsInfoValidator.validate(request)) { error in
                XCTAssertEqual(error as? CredentialsInfoError, .invalidCertificates, "Should throw specific error for invalid certificate type: \(invalidType)")
            }
        }
    }

    func testValidatorSucceedsForNilCertificates() throws {
        let requestWithNilCertificates = CredentialsInfoRequest(
            credentialID: "valid-id",
            certificates: nil,
            certInfo: true,
            authInfo: true,
            lang: nil,
            clientData: nil
        )
        
        XCTAssertNoThrow(try CredentialsInfoValidator.validate(requestWithNilCertificates), "Should accept nil certificates parameter")
    }

    func testValidatorWithMinimalValidRequest() throws {
        let minimalRequest = CredentialsInfoRequest(
            credentialID: "minimal-id",
            certificates: nil,
            certInfo: nil,
            authInfo: nil,
            lang: nil,
            clientData: nil
        )
        
        XCTAssertNoThrow(try CredentialsInfoValidator.validate(minimalRequest), "Should accept minimal valid request")
    }

    func testValidatorEdgeCasesForCredentialID() {
        let edgeCases = [
            ("single-char", "a", true),
            ("whitespace-only", "   ", true),
            ("special-characters", "test-123_@#", true),
            ("unicode", "тест-идентификатор", true),
            ("very-long", String(repeating: "a", count: 1000), true)
        ]
        
        for (testName, credentialID, shouldPass) in edgeCases {
            let request = CredentialsInfoRequest(
                credentialID: credentialID,
                certificates: "chain",
                certInfo: true,
                authInfo: true,
                lang: nil,
                clientData: nil
            )
            
            if shouldPass {
                XCTAssertNoThrow(try CredentialsInfoValidator.validate(request), "Should pass for \(testName): '\(credentialID)'")
            } else {
                XCTAssertThrowsError(try CredentialsInfoValidator.validate(request), "Should fail for \(testName): '\(credentialID)'")
            }
        }
    }

    func testValidatorCaseInsensitiveCertificateTypes() {
        let caseVariations = ["CHAIN", "Chain", "NONE", "None", "SINGLE", "Single"]
        
        for variation in caseVariations {
            let request = CredentialsInfoRequest(
                credentialID: "valid-id",
                certificates: variation,
                certInfo: true,
                authInfo: true,
                lang: nil,
                clientData: nil
            )

            XCTAssertThrowsError(try CredentialsInfoValidator.validate(request)) { error in
                XCTAssertEqual(error as? CredentialsInfoError, .invalidCertificates, "Should be case-sensitive for certificate type: \(variation)")
            }
        }
    }
    
    func testCredentialInfoInitializerWithAllParameters() {
        let keyInfo = CredentialInfo.KeyInfo(status: "enabled", algo: ["1.2.840.10045.2.1"], len: 256, curve: "1.2.840.10045.3.1.7")
        let certInfo = CredentialInfo.CertificateInfo(status: "valid", certificates: ["cert1"], issuerDN: "CN=Test CA", serialNumber: "123", subjectDN: "CN=Test User", validFrom: "20240101000000Z", validTo: "20251231235959Z")
        let authObject = CredentialInfo.AuthObject(type: "PIN", id: "pin1", format: "N", label: "Enter PIN", description: "6-digit PIN")
        let authInfo = CredentialInfo.AuthInfo(mode: "explicit", expression: "PIN", objects: [authObject])
        
        let credentialInfo = CredentialInfo(
            description: "Test credential",
            signatureQualifier: .EU_EIDAS_QES,
            key: keyInfo,
            cert: certInfo,
            auth: authInfo,
            multisign: 5,
            lang: "en-US",
            scal: "1"
        )
        
        XCTAssertEqual(credentialInfo.description, "Test credential")
        XCTAssertEqual(credentialInfo.signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(credentialInfo.key.status, "enabled")
        XCTAssertEqual(credentialInfo.cert?.status, "valid")
        XCTAssertEqual(credentialInfo.auth?.mode, "explicit")
        XCTAssertEqual(credentialInfo.multisign, 5)
        XCTAssertEqual(credentialInfo.lang, "en-US")
        XCTAssertEqual(credentialInfo.scal, "1")
    }
    
    func testCredentialInfoInitializerWithMinimalParameters() {
        let keyInfo = CredentialInfo.KeyInfo(status: "enabled", algo: ["1.2.840.10045.2.1"], len: 256, curve: nil)
        
        let credentialInfo = CredentialInfo(
            key: keyInfo,
            multisign: 1
        )
        
        XCTAssertNil(credentialInfo.description)
        XCTAssertNil(credentialInfo.signatureQualifier)
        XCTAssertEqual(credentialInfo.key.status, "enabled")
        XCTAssertNil(credentialInfo.cert)
        XCTAssertNil(credentialInfo.auth)
        XCTAssertEqual(credentialInfo.multisign, 1)
        XCTAssertNil(credentialInfo.lang)
        XCTAssertNil(credentialInfo.scal)
    }
    
    func testCredentialInfoKeyInfoInitializer() {
        let keyInfo = CredentialInfo.KeyInfo(status: "disabled", algo: ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"], len: 384, curve: "1.2.840.10045.3.1.7")
        
        XCTAssertEqual(keyInfo.status, "disabled")
        XCTAssertEqual(keyInfo.algo, ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"])
        XCTAssertEqual(keyInfo.len, 384)
        XCTAssertEqual(keyInfo.curve, "1.2.840.10045.3.1.7")
    }
    
    func testCredentialInfoCertificateInfoInitializer() {
        let certInfo = CredentialInfo.CertificateInfo(
            status: "revoked",
            certificates: ["cert1", "cert2"],
            issuerDN: "CN=Test CA, O=Test Org",
            serialNumber: "987654321",
            subjectDN: "CN=John Doe, O=User Org",
            validFrom: "20230101000000Z",
            validTo: "20241231235959Z"
        )
        
        XCTAssertEqual(certInfo.status, "revoked")
        XCTAssertEqual(certInfo.certificates, ["cert1", "cert2"])
        XCTAssertEqual(certInfo.issuerDN, "CN=Test CA, O=Test Org")
        XCTAssertEqual(certInfo.serialNumber, "987654321")
        XCTAssertEqual(certInfo.subjectDN, "CN=John Doe, O=User Org")
        XCTAssertEqual(certInfo.validFrom, "20230101000000Z")
        XCTAssertEqual(certInfo.validTo, "20241231235959Z")
    }
    
    func testCredentialInfoAuthInfoInitializer() {
        let authObject1 = CredentialInfo.AuthObject(type: "PIN", id: "pin1", format: "N", label: "Primary PIN", description: "Main PIN")
        let authObject2 = CredentialInfo.AuthObject(type: "BIOMETRIC", id: "bio1", format: "B", label: "Fingerprint", description: "Touch sensor")
        
        let authInfo = CredentialInfo.AuthInfo(
            mode: "implicit",
            expression: "PIN || BIOMETRIC",
            objects: [authObject1, authObject2]
        )
        
        XCTAssertEqual(authInfo.mode, "implicit")
        XCTAssertEqual(authInfo.expression, "PIN || BIOMETRIC")
        XCTAssertEqual(authInfo.objects?.count, 2)
        
        XCTAssertEqual(authInfo.objects?[0].type, "PIN")
        XCTAssertEqual(authInfo.objects?[0].id, "pin1")
        XCTAssertEqual(authInfo.objects?[1].type, "BIOMETRIC")
        XCTAssertEqual(authInfo.objects?[1].id, "bio1")
    }
    
    func testCredentialInfoAuthObjectInitializer() {
        let authObject = CredentialInfo.AuthObject(
            type: "SMART_CARD",
            id: "card1",
            format: "C",
            label: "Smart Card",
            description: "Insert smart card"
        )
        
        XCTAssertEqual(authObject.type, "SMART_CARD")
        XCTAssertEqual(authObject.id, "card1")
        XCTAssertEqual(authObject.format, "C")
        XCTAssertEqual(authObject.label, "Smart Card")
        XCTAssertEqual(authObject.description, "Insert smart card")
    }
} 
