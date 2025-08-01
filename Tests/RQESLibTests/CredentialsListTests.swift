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

class CredentialsListTests: XCTestCase {

    func testRequestJSONEncodingWithAllParameters() throws {
        let request = CredentialsListRequest(
            userID: "test-user",
            credentialInfo: true,
            certificates: "chain",
            certInfo: false,
            authInfo: true,
            onlyValid: false,
            lang: "en-US",
            clientData: "custom-data"
        )
        
        let jsonData = try JSONEncoder().encode(request)
        let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        XCTAssertNotNil(jsonDict, "Should produce valid JSON")
        XCTAssertEqual(jsonDict?["user_id"] as? String, "test-user")
        XCTAssertEqual(jsonDict?["credentialInfo"] as? Bool, true)
        XCTAssertEqual(jsonDict?["certificates"] as? String, "chain")
        XCTAssertEqual(jsonDict?["certInfo"] as? Bool, false)
        XCTAssertEqual(jsonDict?["auth_info"] as? Bool, true)
        XCTAssertEqual(jsonDict?["only_valid"] as? Bool, false)
        XCTAssertEqual(jsonDict?["lang"] as? String, "en-US")
        XCTAssertEqual(jsonDict?["client_data"] as? String, "custom-data")
    }

    func testRequestJSONEncodingWithMinimalParameters() throws {
        let request = CredentialsListRequest()
        
        let jsonData = try JSONEncoder().encode(request)
        let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        
        XCTAssertNotNil(jsonDict, "Should produce valid JSON for minimal request")

        XCTAssertEqual(jsonDict?["certInfo"] as? Bool, true, "Should include default certInfo value")

        XCTAssertNil(jsonDict?["user_id"], "Should not include nil userID")
        XCTAssertNil(jsonDict?["credentialInfo"], "Should not include nil credentialInfo")
        XCTAssertNil(jsonDict?["certificates"], "Should not include nil certificates")
    }

    func testRequestJSONDecodingRoundTrip() throws {
        let originalRequest = CredentialsListRequest(
            userID: "round-trip-user",
            credentialInfo: false,
            certificates: "single",
            certInfo: true,
            authInfo: false,
            onlyValid: true,
            lang: "de-DE",
            clientData: "round-trip-data"
        )
        
        let jsonData = try JSONEncoder().encode(originalRequest)
        let decodedRequest = try JSONDecoder().decode(CredentialsListRequest.self, from: jsonData)
        
        XCTAssertEqual(decodedRequest.userID, originalRequest.userID)
        XCTAssertEqual(decodedRequest.credentialInfo, originalRequest.credentialInfo)
        XCTAssertEqual(decodedRequest.certificates, originalRequest.certificates)
        XCTAssertEqual(decodedRequest.certInfo, originalRequest.certInfo)
        XCTAssertEqual(decodedRequest.authInfo, originalRequest.authInfo)
        XCTAssertEqual(decodedRequest.onlyValid, originalRequest.onlyValid)
        XCTAssertEqual(decodedRequest.lang, originalRequest.lang)
        XCTAssertEqual(decodedRequest.clientData, originalRequest.clientData)
    }

    func testRequestFormBodyGenerationWithAllParameters() {
        let request = CredentialsListRequest(
            userID: "form-user",
            credentialInfo: true,
            certificates: "chain",
            certInfo: false,
            authInfo: true,
            onlyValid: false,
            lang: "fr-FR",
            clientData: "form-data"
        )
        
        let formData = request.toFormBody()
        let formString = String(data: formData, encoding: .utf8)
        
        XCTAssertNotNil(formString, "Should generate valid form body")
        
        let expectedPairs = [
            "user_id=form-user",
            "credential_info=true",
            "certificates=chain",
            "cert_info=false",
            "auth_info=true",
            "only_valid=false",
            "lang=fr-FR",
            "client_data=form-data"
        ]
        
        for expectedPair in expectedPairs {
            XCTAssertTrue(formString?.contains(expectedPair) == true, "Form body should contain: \(expectedPair)")
        }
    }

    func testRequestFormBodyGenerationWithMinimalParameters() {
        let request = CredentialsListRequest()
        
        let formData = request.toFormBody()
        let formString = String(data: formData, encoding: .utf8)
        
        XCTAssertNotNil(formString, "Should generate valid form body for minimal request")

        XCTAssertTrue(formString?.contains("cert_info=true") == true, "Should contain default certInfo")

        XCTAssertFalse(formString?.contains("user_id=") == true, "Should not contain nil userID")
        XCTAssertFalse(formString?.contains("credential_info=") == true, "Should not contain nil credentialInfo")
    }

    func testRequestFormBodyBooleanConversion() {
        let trueRequest = CredentialsListRequest(
            userID: nil,
            credentialInfo: true,
            certificates: nil,
            certInfo: true,
            authInfo: true,
            onlyValid: true,
            lang: nil,
            clientData: nil
        )
        
        let falseRequest = CredentialsListRequest(
            userID: nil,
            credentialInfo: false,
            certificates: nil,
            certInfo: false,
            authInfo: false,
            onlyValid: false,
            lang: nil,
            clientData: nil
        )
        
        let trueFormString = String(data: trueRequest.toFormBody(), encoding: .utf8)
        let falseFormString = String(data: falseRequest.toFormBody(), encoding: .utf8)

        XCTAssertTrue(trueFormString?.contains("credential_info=true") == true, "Should convert true to 'true'")
        XCTAssertTrue(trueFormString?.contains("cert_info=true") == true, "Should convert true to 'true'")
        XCTAssertTrue(trueFormString?.contains("auth_info=true") == true, "Should convert true to 'true'")
        XCTAssertTrue(trueFormString?.contains("only_valid=true") == true, "Should convert true to 'true'")

        XCTAssertTrue(falseFormString?.contains("credential_info=false") == true, "Should convert false to 'false'")
        XCTAssertTrue(falseFormString?.contains("cert_info=false") == true, "Should convert false to 'false'")
        XCTAssertTrue(falseFormString?.contains("auth_info=false") == true, "Should convert false to 'false'")
        XCTAssertTrue(falseFormString?.contains("only_valid=false") == true, "Should convert false to 'false'")
    }

    func testRequestFormBodySpecialCharactersHandling() {
        let request = CredentialsListRequest(
            userID: "user@example.com",
            credentialInfo: nil,
            certificates: "chain&more",
            certInfo: true,
            authInfo: nil,
            onlyValid: nil,
            lang: "en-US",
            clientData: "data with spaces"
        )
        
        let formData = request.toFormBody()
        let formString = String(data: formData, encoding: .utf8)
        
        XCTAssertNotNil(formString, "Should handle special characters in form body")
        XCTAssertTrue(formString?.contains("user_id=user@example.com") == true, "Should preserve email format")
        XCTAssertTrue(formString?.contains("certificates=chain&more") == true, "Should preserve ampersand")
        XCTAssertTrue(formString?.contains("client_data=data with spaces") == true, "Should preserve spaces")
    }

    func testRequestInitializerDefaultValues() {
        let request = CredentialsListRequest()
        
        XCTAssertNil(request.userID, "userID should default to nil")
        XCTAssertNil(request.credentialInfo, "credentialInfo should default to nil")
        XCTAssertNil(request.certificates, "certificates should default to nil")
        XCTAssertEqual(request.certInfo, true, "certInfo should default to true")
        XCTAssertNil(request.authInfo, "authInfo should default to nil")
        XCTAssertNil(request.onlyValid, "onlyValid should default to nil")
        XCTAssertNil(request.lang, "lang should default to nil")
        XCTAssertNil(request.clientData, "clientData should default to nil")
    }

    func testResponseDecodingCompleteResponse() throws {
        let jsonData = TestConstants.completeCredentialsListResponse.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)

        XCTAssertEqual(response.credentialIDs, ["test-credential-123"])
        XCTAssertEqual(response.onlyValid, true)
        XCTAssertEqual(response.credentialInfos?.count, 1)

        guard let credential = response.credentialInfos?.first else {
            XCTFail("Should have one credential")
            return
        }
        
        XCTAssertEqual(credential.credentialID, "test-credential-123")
        XCTAssertEqual(credential.description, "Test credential")
        XCTAssertEqual(credential.signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(credential.multisign, 5)
        XCTAssertEqual(credential.lang, "en-US")

        XCTAssertEqual(credential.cert.serialNumber, "123456789")
        XCTAssertEqual(credential.cert.certificates, ["cert1", "cert2"])
        XCTAssertEqual(credential.cert.status, "valid")
        XCTAssertEqual(credential.cert.subjectDN, "C=US, CN=Test User")
        XCTAssertEqual(credential.cert.issuerDN, "C=US, O=Test CA")

        XCTAssertEqual(credential.key.status, "enabled")
        XCTAssertEqual(credential.key.curve, "1.2.840.10045.3.1.7")
        XCTAssertEqual(credential.key.algo, ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"])
        XCTAssertEqual(credential.key.len, 256)
    }

    func testResponseDecodingEmptyCredentialsList() throws {
        let jsonData = TestConstants.emptyCredentialsListResponse.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)
        
        XCTAssertEqual(response.credentialIDs, [])
        XCTAssertEqual(response.onlyValid, false)
        XCTAssertEqual(response.credentialInfos?.count, 0)
    }

    func testResponseDecodingMultipleCredentials() throws {
        let jsonData = TestConstants.multipleCredentialsListResponse.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)
        
        XCTAssertEqual(response.credentialIDs, ["cred-1", "cred-2"])
        XCTAssertEqual(response.credentialInfos?.count, 2)
        
        let firstCred = response.credentialInfos?[0]
        let secondCred = response.credentialInfos?[1]
        
        XCTAssertEqual(firstCred?.credentialID, "cred-1")
        XCTAssertEqual(firstCred?.signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(firstCred?.multisign, 1)
        
        XCTAssertEqual(secondCred?.credentialID, "cred-2")
        XCTAssertEqual(secondCred?.signatureQualifier?.rawValue, "eu_eidas_ades")
        XCTAssertEqual(secondCred?.multisign, 3)
    }

    func testResponseDecodingWithOptionalFieldsMissing() throws {
        let jsonData = TestConstants.minimalCredentialsListResponse.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)
        
        XCTAssertEqual(response.credentialIDs, ["minimal-cred"])
        XCTAssertNil(response.onlyValid, "onlyValid should be nil when not provided")
        
        guard let credential = response.credentialInfos?.first else {
            XCTFail("Should have one credential")
            return
        }
        
        XCTAssertEqual(credential.credentialID, "minimal-cred")
        XCTAssertNil(credential.description, "description should be nil when not provided")
        XCTAssertNil(credential.signatureQualifier, "signatureQualifier should be nil when not provided")
        XCTAssertNil(credential.multisign, "multisign should be nil when not provided")
        XCTAssertNil(credential.lang, "lang should be nil when not provided")
        XCTAssertNil(credential.auth, "auth should be nil when not provided")
        XCTAssertNil(credential.scal, "scal should be nil when not provided")

        XCTAssertEqual(credential.cert.serialNumber, "999")
        XCTAssertEqual(credential.key.status, "enabled")
    }

    func testResponseDecodingWithNullCredentialInfos() throws {
        let jsonData = TestConstants.nullCredentialInfosResponse.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)
        
        XCTAssertEqual(response.credentialIDs, ["id-without-info"])
        XCTAssertEqual(response.onlyValid, false)
        XCTAssertNil(response.credentialInfos, "credentialInfos should be nil when explicitly null")
    }

    func testResponseDecodingFailsWithMissingRequiredFields() {        
        for invalidJson in TestConstants.invalidCredentialsListJsons {
            let jsonData = invalidJson.data(using: .utf8)!
            
            XCTAssertThrowsError(try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)) { error in
                XCTAssertTrue(error is DecodingError, "Should throw DecodingError for missing required fields")
            }
        }
    }

    func testResponseDecodingPreservesSignatureQualifierVariants() throws {
        let qualifierVariants = ["eu_eidas_qes", "eu_eidas_ades", "eu_eidas_qeseal", "eu_eidas_adeseal"]
        
        for qualifier in qualifierVariants {
            let jsonData = TestConstants.credentialsListResponseWithSignatureQualifier(qualifier).data(using: .utf8)!
            
            let response = try JSONDecoder().decode(CredentialsListResponse.self, from: jsonData)
            
            XCTAssertEqual(response.credentialInfos?.first?.signatureQualifier?.rawValue, qualifier, "Should preserve signature qualifier: \(qualifier)")
        }
    }

    func testValidatorSucceedsForValidClientID() throws {
        let validClientIDs = [
            "valid-client-id",
            "client123",
            "my_client",
            "ClientID",
            "1234567890",
        ]
        
        for clientID in validClientIDs {
            XCTAssertNoThrow(
                try CredentialsListValidator.validate(clientID),
                "Should accept valid client ID: '\(clientID)'"
            )
        }
    }

    func testValidatorFailsForEmptyClientID() {
        let emptyClientID = ""
        
        XCTAssertThrowsError(try CredentialsListValidator.validate(emptyClientID)) { error in
            XCTAssertEqual(error as? CredentialsListError, .invalidClientID, "Should throw specific error for empty client ID")
        }
    }

    func testValidatorTypeDefinition() {
        XCTAssertTrue(CredentialsListValidator.Input.self == String.self, "Should have String as Input type")

        let testInput = "test-validation"
        XCTAssertNoThrow(try CredentialsListValidator.validate(testInput), "Should have working validate method")
    }

    func testValidatorIsStateless() throws {
        let testClientID = "stateless-test-client"

        try CredentialsListValidator.validate(testClientID)
        try CredentialsListValidator.validate(testClientID)
        try CredentialsListValidator.validate(testClientID)

        try CredentialsListValidator.validate("different-client-1")
        try CredentialsListValidator.validate("different-client-2")

        XCTAssertNoThrow(
            try CredentialsListValidator.validate(testClientID),
            "Validator should be stateless and not affected by previous calls"
        )
    }

    func testValidatorErrorMessageIsDescriptive() {
        do {
            try CredentialsListValidator.validate("")
            XCTFail("Should have thrown an error")
        } catch let error as CredentialsListError {
            XCTAssertEqual(error, .invalidClientID)
            XCTAssertNotNil(error.errorDescription, "Error should have a description")
            XCTAssertEqual(error.errorDescription, "The client ID provided is invalid.")
        } catch {
            XCTFail("Should have thrown CredentialsListError, but got: \(error)")
        }
    }

} 
