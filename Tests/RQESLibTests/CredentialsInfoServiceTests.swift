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

class CredentialsInfoServiceTests: XCTestCase {
    var mockHTTPClient: MockHTTPClient!
    var credentialsInfoClient: CredentialsInfoClient!
    var service: CredentialsInfoService!

    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        credentialsInfoClient = CredentialsInfoClient(httpClient: mockHTTPClient)
        service = CredentialsInfoService(credentialsInfoClient: credentialsInfoClient)
    }

    override func tearDown() {
        service = nil
        credentialsInfoClient = nil
        mockHTTPClient = nil
        super.tearDown()
    }

    func testGetCredentialsInfoSuccessfulIntegration() async throws {
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsInfoRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await service.getCredentialsInfo(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.description, "This is a credential for tests")
        XCTAssertEqual(response.signatureQualifier?.rawValue, "eu_eidas_qes")
        XCTAssertEqual(response.multisign, 1)
        XCTAssertEqual(response.lang, "en-US")

        XCTAssertNotNil(response.cert, "Certificate should be present")
        XCTAssertEqual(response.cert?.serialNumber, "184966370757515800362535864175063713398032096472")
        XCTAssertEqual(response.cert?.status, "valid")
        XCTAssertEqual(response.cert?.certificates?.count, 2, "Should contain certificate chain")

        XCTAssertEqual(response.key.status, "enabled")
        XCTAssertEqual(response.key.len, 256)
        XCTAssertEqual(response.key.algo.count, 2, "Should contain multiple algorithms")
    }

    func testGetCredentialsInfoValidationFailsForEmptyCredentialID() async {
        let invalidRequest = CredentialsInfoRequest(
            credentialID: "",
            certificates: "chain",
            certInfo: true,
            authInfo: true,
            lang: nil,
            clientData: nil
        )
        
        do {
            _ = try await service.getCredentialsInfo(request: invalidRequest, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
            XCTFail("Expected validation error for empty credentialID")
        } catch let error as CredentialsInfoError {
            XCTAssertEqual(error, .missingCredentialID, "Should throw specific validation error")
        } catch {
            XCTFail("Expected CredentialsInfoError.missingCredentialID, but got \(type(of: error)): \(error)")
        }
    }

    func testGetCredentialsInfoValidationFailsForInvalidCertificates() async {
        let invalidRequest = CredentialsInfoRequest(
            credentialID: "valid-id",
            certificates: "invalid-cert-type",
            certInfo: true,
            authInfo: true,
            lang: nil,
            clientData: nil
        )
        
        do {
            _ = try await service.getCredentialsInfo(request: invalidRequest, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
            XCTFail("Expected validation error for invalid certificates parameter")
        } catch let error as CredentialsInfoError {
            XCTAssertEqual(error, .invalidCertificates, "Should throw specific validation error")
        } catch {
            XCTFail("Expected CredentialsInfoError.invalidCertificates, but got \(type(of: error)): \(error)")
        }
    }

    func testGetCredentialsInfoValidationPassesForValidCertificateTypes() async throws {
        let validCertificateTypes = ["none", "single", "chain"]
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        
        for certType in validCertificateTypes {
            let validRequest = CredentialsInfoRequest(
                credentialID: "valid-id",
                certificates: certType,
                certInfo: true,
                authInfo: true,
                lang: nil,
                clientData: nil
            )
            
            mockHTTPClient.setMockResponse(for: url, data: responseData, statusCode: 200)
            
            do {
                let response = try await service.getCredentialsInfo(request: validRequest, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
                XCTAssertEqual(response.description, "This is a credential for tests", "Should succeed for valid certificate type: \(certType)")
            } catch {
                XCTFail("Should accept valid certificate type '\(certType)', but got error: \(error)")
            }
        }
    }

    func testGetCredentialsInfoValidationAllowsNilCertificates() async throws {
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let requestWithNilCerts = CredentialsInfoRequest(
            credentialID: "valid-id",
            certificates: nil,
            certInfo: true,
            authInfo: true,
            lang: nil,
            clientData: nil
        )
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await service.getCredentialsInfo(request: requestWithNilCerts, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
        XCTAssertEqual(response.description, "This is a credential for tests", "Should accept nil certificates parameter")
    }

    func testGetCredentialsInfoPropagatesClientErrors() async {
        let request = TestConstants.standardCredentialsInfoRequest
        let url = try! TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        
        let testCases: [(statusCode: Int, message: String)] = [
            (400, "Bad Request"),
            (401, "Unauthorized"),
            (404, "Credential not found"),
            (500, "Internal Server Error")
        ]
        
        for testCase in testCases {
            mockHTTPClient.setMockResponse(for: url, data: testCase.message.data(using: .utf8)!, statusCode: testCase.statusCode)
            
            do {
                _ = try await service.getCredentialsInfo(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
                XCTFail("Expected error for HTTP \(testCase.statusCode)")
            } catch ClientError.clientError(let message, let statusCode) {
                XCTAssertEqual(statusCode, testCase.statusCode, "Should propagate correct status code")
                XCTAssertEqual(message, testCase.message, "Should propagate correct error message")
            } catch {
                XCTFail("Expected ClientError.clientError for HTTP \(testCase.statusCode), but got \(type(of: error)): \(error)")
            }
        }
    }

    func testGetCredentialsInfoPropagatesNetworkErrors() async {
        let request = TestConstants.standardCredentialsInfoRequest
        let networkError = URLError(.notConnectedToInternet)
        mockHTTPClient.setMockError(networkError)
        
        do {
            _ = try await service.getCredentialsInfo(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)
            XCTFail("Expected network error to be propagated")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet, "Should propagate specific network error")
        } catch {
            XCTFail("Expected URLError, but got \(type(of: error)): \(error)")
        }
    }

    func testServiceUsesDependencyInjectedClient() async throws {
        let capturingMock = CapturingMockHTTPClient()
        let customClient = CredentialsInfoClient(httpClient: capturingMock)
        let customService = CredentialsInfoService(credentialsInfoClient: customClient)
        
        let responseData = TestConstants.credentialsInfoResponse.data(using: .utf8)!
        let request = TestConstants.standardCredentialsInfoRequest
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        capturingMock.setMockResponse(for: url, data: responseData, statusCode: 200)
        
        let response = try await customService.getCredentialsInfo(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.description, "This is a credential for tests")

        XCTAssertNotNil(capturingMock.lastCapturedRequest, "Should use injected client")
        XCTAssertTrue(capturingMock.lastCapturedRequest?.url?.absoluteString.contains("/credentials/info") == true, "Should call correct endpoint through injected client")
    }

    func testGetCredentialsInfoWithDifferentCredentialTypes() async throws {
        let customResponseData = """
        {
          "signatureQualifier" : "eu_eidas_ades",
          "description" : "Advanced Electronic Signature credential",
          "lang" : "es-ES",
          "key" : {
            "status" : "enabled",
            "curve" : "1.2.840.10045.3.1.7",
            "algo" : ["1.2.840.10045.2.1"],
            "len" : 256
          },
          "multisign" : 5,
          "cert" : {
            "validFrom" : "20240101000000Z",
            "serialNumber" : "987654321",
            "subjectDN" : "C=ES, CN=Test User",
            "validTo" : "20250101000000Z",
            "certificates" : ["base64-cert-data"],
            "issuerDN" : "C=ES, O=Test CA",
            "status" : "valid"
          }
        }
        """.data(using: .utf8)!
        
        let request = CredentialsInfoRequest(
            credentialID: "different-credential-id",
            certificates: "single",
            certInfo: true,
            authInfo: false,
            lang: "es-ES",
            clientData: nil
        )
        
        let url = try TestConstants.rsspUrl.appendingEndpoint("/credentials/info").get().absoluteString
        mockHTTPClient.setMockResponse(for: url, data: customResponseData, statusCode: 200)
        
        let response = try await service.getCredentialsInfo(request: request, accessToken: "testToken", rsspUrl: TestConstants.rsspUrl)

        XCTAssertEqual(response.signatureQualifier?.rawValue, "eu_eidas_ades")
        XCTAssertEqual(response.description, "Advanced Electronic Signature credential")
        XCTAssertEqual(response.multisign, 5)
        XCTAssertEqual(response.lang, "es-ES")
        XCTAssertEqual(response.key.algo.count, 1)
        XCTAssertEqual(response.cert?.certificates?.count, 1)
    }
} 
