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

final class CrlClientTests: XCTestCase {
    
    var mockHTTPClient: MockHTTPClient!
    var crlClient: CrlClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        crlClient = CrlClient(httpClient: mockHTTPClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        crlClient = nil
        super.tearDown()
    }
    
    func testMakeRequestWithValidCrlUrl() async {
        let crlUrl = "https://mock-ca.example.com/ca.crl"
        let mockCrlData = Data("MOCK_CRL_DATA".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertFalse(data.isEmpty, "Response data should not be empty")
            XCTAssertEqual(data, mockCrlData, "Should return exact mocked CRL data - proves MockHTTPClient is being used")
            
            let responseString = String(data: data, encoding: .utf8)
            XCTAssertEqual(responseString, "MOCK_CRL_DATA", "Should return exact mock string content")
            
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestWithValidHttpsCrlUrl() async {
        let crlUrl = "https://mock-ca.example.com/https-ca.crl"
        let mockCrlData = Data("MOCK_HTTPS_CRL_DATA".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertEqual(data, mockCrlData, "Should return mocked CRL data")
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        case .none:
            XCTFail("Should return a result")
        }
    }

    func testMakeRequestWithEmptyURL() async {
        let request = CrlRequest(crlUrl: "")

        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with empty URL")
        case .failure(let error):
            XCTAssertEqual(error, ClientError.invalidRequestURL, "Should return invalidRequestURL error")
        case .none:
            break
        }
    }

    func testMakeRequestWithInvalidURL() async {
        let request = CrlRequest(crlUrl: "not-a-valid-url-at-all")

        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with invalid URL")
        case .failure(let error):
            XCTAssertTrue(error == ClientError.invalidRequestURL || error == ClientError.noData, 
                         "Should return invalidRequestURL or noData error for malformed URL")
        case .none:
            break
        }
    }
    
    func testMakeRequestWithUnreachableURL() async {
        let crlUrl = "https://unreachable-crl-server.com/ca.crl"
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with unreachable URL")
        case .failure(let error):
            XCTAssertEqual(error, ClientError.noData, "Should return noData when MockHTTPClient has no response configured")
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestWithNonExistentPath() async {
        let crlUrl = "https://mock-ca.example.com/not-found.crl"
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Not Found".utf8), statusCode: 404)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with 404 status")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 404, "Should return exact mock 404 status code")
                XCTAssertEqual(message, "Not Found", "Should return exact mock error message")
            } else {
                XCTFail("Should return clientError with 404 status")
            }
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestHandlesHTTPErrorStatusCodes() async {
        let crlUrl = "https://mock-ca.example.com/server-error.crl"
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Server Error".utf8), statusCode: 500)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with 500 status")
        case .failure(let error):
            if case .clientError(_, let statusCode) = error {
                XCTAssertEqual(statusCode, 500, "Should return 500 status code")
            } else {
                XCTFail("Should return clientError with 500 status")
            }
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestHandlesUnauthorizedAccess() async {
        let crlUrl = "https://mock-ca.example.com/unauthorized.crl"
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Unauthorized".utf8), statusCode: 401)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with 401 status")
        case .failure(let error):
            if case .clientError(_, let statusCode) = error {
                XCTAssertEqual(statusCode, 401, "Should return 401 status code")
            } else {
                XCTFail("Should return clientError with 401 status")
            }
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestIntegrationWithRealCrlEndpoint() async {
        let crlUrl = "https://mock-ca.example.com/integration-crl.crl"
        let mockCrlData = Data("MOCK_INTEGRATION_CRL_DATA_WITH_CONTENT".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertFalse(data.isEmpty, "Response data should not be empty")
            XCTAssertTrue(data.count > 0, "Response should have content")
            XCTAssertEqual(data, mockCrlData, "Should return mocked CRL data")
            
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestReturnsActualCrlData() async {
        let crlUrl = "https://mock-ca.example.com/substantial-data.crl"
        let mockCrlData = Data(String(repeating: "MOCK_SUBSTANTIAL_CRL_CONTENT_", count: 5).utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertTrue(data.count > 100, "CRL data should be substantial")
            XCTAssertEqual(data, mockCrlData, "Should return mocked CRL data")
            
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testCrlRequestCreation() {
        let url = "https://example.com/test.crl"
        let request = CrlRequest(crlUrl: url)
        
        XCTAssertEqual(request.crlUrl, url, "CrlRequest should store URL correctly")
    }
    
    func testCrlResponseCreation() {
        let base64Data = "dGVzdCBkYXRh"
        let response = CrlResponse(crlInfoBase64: base64Data)
        
        XCTAssertEqual(response.crlInfoBase64, base64Data, "CrlResponse should store base64 data correctly")
    }
    
    func testConformanceLevelEnum() {
        XCTAssertEqual(ConformanceLevel.ADES_B_B.rawValue, "ADES_B_B")
        XCTAssertEqual(ConformanceLevel.ADES_B_T.rawValue, "ADES_B_T")
        XCTAssertEqual(ConformanceLevel.ADES_B_LT.rawValue, "ADES_B_LT")
        XCTAssertEqual(ConformanceLevel.ADES_B_LTA.rawValue, "ADES_B_LTA")
        
        let customLevel = ConformanceLevel("CUSTOM_LEVEL")
        XCTAssertEqual(customLevel.rawValue, "CUSTOM_LEVEL")
        
        let literalLevel: ConformanceLevel = "LITERAL_LEVEL"
        XCTAssertEqual(literalLevel.rawValue, "LITERAL_LEVEL")
        
        XCTAssertEqual(ConformanceLevel.ADES_B_B.description, "ADES_B_B")
        
        XCTAssertEqual(ConformanceLevel.ADES_B_B.rawValue, ConformanceLevel.ADES_B_B.rawValue)
        XCTAssertNotEqual(ConformanceLevel.ADES_B_B.rawValue, ConformanceLevel.ADES_B_T.rawValue)
    }
    
    func testSignatureFormatEnum() {
        XCTAssertEqual(SignatureFormat.C.rawValue, "C")
        XCTAssertEqual(SignatureFormat.X.rawValue, "X")
        XCTAssertEqual(SignatureFormat.P.rawValue, "P")
        XCTAssertEqual(SignatureFormat.J.rawValue, "J")
        
        let customFormat = SignatureFormat("CUSTOM")
        XCTAssertEqual(customFormat.rawValue, "CUSTOM")
        
        let literalFormat: SignatureFormat = "LITERAL"
        XCTAssertEqual(literalFormat.rawValue, "LITERAL")
        
        XCTAssertEqual(SignatureFormat.C.description, "C")
        XCTAssertEqual(SignatureFormat.C.rawValue, SignatureFormat.C.rawValue)
        XCTAssertNotEqual(SignatureFormat.C.rawValue, SignatureFormat.X.rawValue)
    }
    
    func testSignatureQualifierEnum() {
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_QES.rawValue, "eu_eidas_qes")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AES.rawValue, "eu_eidas_aes")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AESQC.rawValue, "eu_eidas_aesqc")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_QESEAL.rawValue, "eu_eidas_qeseal")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AESEAL.rawValue, "eu_eidas_aeseal")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_AESEALQC.rawValue, "eu_eidas_aesealqc")
        
        XCTAssertEqual(SignatureQualifier.ZA_ECTA_AES.rawValue, "za_ecta_aes")
        XCTAssertEqual(SignatureQualifier.ZA_ECTA_OES.rawValue, "za_ecta_oes")
        
        let customQualifier = SignatureQualifier("custom_qualifier")
        XCTAssertEqual(customQualifier.rawValue, "custom_qualifier")
        
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_QES.description, "eu_eidas_qes")
        XCTAssertEqual(SignatureQualifier.EU_EIDAS_QES.rawValue, SignatureQualifier.EU_EIDAS_QES.rawValue)
        XCTAssertNotEqual(SignatureQualifier.EU_EIDAS_QES.rawValue, SignatureQualifier.EU_EIDAS_AES.rawValue)
    }
    
    func testScopeEnum() {
        XCTAssertEqual(Scope.SERVICE.rawValue, "service")
        XCTAssertEqual(Scope.CREDENTIAL.rawValue, "credential")
        
        let customScope = Scope("custom_scope")
        XCTAssertEqual(customScope.rawValue, "custom_scope")
        
        let literalScope: Scope = "literal_scope"
        XCTAssertEqual(literalScope.rawValue, "literal_scope")
        
        XCTAssertEqual(Scope.SERVICE.description, "service")
        XCTAssertEqual(Scope.SERVICE.rawValue, Scope.SERVICE.rawValue)
        XCTAssertNotEqual(Scope.SERVICE.rawValue, Scope.CREDENTIAL.rawValue)
    }
    
    func testHashAlgorithmOID() {
        XCTAssertEqual(HashAlgorithmOID.SHA256.rawValue, "2.16.840.1.101.3.4.2.1")
        XCTAssertEqual(HashAlgorithmOID.SHA385.rawValue, "2.16.840.1.101.3.4.2.2") 
        XCTAssertEqual(HashAlgorithmOID.SHA512.rawValue, "2.16.840.1.101.3.4.2.3")
        XCTAssertEqual(HashAlgorithmOID.SHA3_256.rawValue, "2.16.840.1.101.3.4.2.8")
        XCTAssertEqual(HashAlgorithmOID.SHA3_385.rawValue, "2.16.840.1.101.3.4.2.9")
        XCTAssertEqual(HashAlgorithmOID.SHA3_512.rawValue, "2.16.840.1.101.3.4.2.10")
        
        let customOID = HashAlgorithmOID("1.2.3.4.5")
        XCTAssertEqual(customOID.rawValue, "1.2.3.4.5")
        
        XCTAssertEqual(HashAlgorithmOID.SHA256.description, "2.16.840.1.101.3.4.2.1")
        XCTAssertEqual(HashAlgorithmOID.SHA256.rawValue, HashAlgorithmOID.SHA256.rawValue)
        XCTAssertNotEqual(HashAlgorithmOID.SHA256.rawValue, HashAlgorithmOID.SHA385.rawValue)
    }
    
    func testSigningAlgorithmOID() {
        XCTAssertEqual(SigningAlgorithmOID.RSA.rawValue, "1.2.840.113549.1.1.1")
        XCTAssertEqual(SigningAlgorithmOID.SHA256WithRSA.rawValue, "1.2.840.113549.1.1.11")
        XCTAssertEqual(SigningAlgorithmOID.SHA384WithRSA.rawValue, "1.2.840.113549.1.1.12")
        XCTAssertEqual(SigningAlgorithmOID.SHA512WithRSA.rawValue, "1.2.840.113549.1.1.13")
        XCTAssertEqual(SigningAlgorithmOID.ECDSA.rawValue, "1.2.840.10045.2.1")
        XCTAssertEqual(SigningAlgorithmOID.SHA256WithECDSA.rawValue, "1.2.840.10045.4.3.2")
        XCTAssertEqual(SigningAlgorithmOID.SHA384WithECDSA.rawValue, "1.2.840.10045.4.3.3")
        XCTAssertEqual(SigningAlgorithmOID.SHA512WithECDSA.rawValue, "1.2.840.10045.4.3.4")
        XCTAssertEqual(SigningAlgorithmOID.DSA.rawValue, "1.2.840.10040.4.1")
        
        let customSigningOID = SigningAlgorithmOID("1.2.3.4.5.6")
        XCTAssertEqual(customSigningOID.rawValue, "1.2.3.4.5.6")
        
        XCTAssertEqual(SigningAlgorithmOID.RSA.description, "1.2.840.113549.1.1.1")
        XCTAssertEqual(SigningAlgorithmOID.SHA256WithECDSA.rawValue, SigningAlgorithmOID.SHA256WithECDSA.rawValue)
        XCTAssertNotEqual(SigningAlgorithmOID.SHA256WithECDSA.rawValue, SigningAlgorithmOID.SHA384WithECDSA.rawValue)
    }
    
    func testClientErrorTypes() {
        let invalidRequestError = ClientError.invalidRequestURL
        let noDataError = ClientError.noData
        let invalidResponseError = ClientError.invalidResponse
        let encodingFailedError = ClientError.encodingFailed
        let clientError = ClientError.clientError(message: "Test error", statusCode: 400)
        let httpError = ClientError.httpError(statusCode: 500)
        
        XCTAssertNotEqual(invalidRequestError, noDataError)
        XCTAssertNotEqual(noDataError, invalidResponseError)
        XCTAssertNotEqual(invalidResponseError, encodingFailedError)
        
        if case .clientError(let message, let statusCode) = clientError {
            XCTAssertEqual(message, "Test error")
            XCTAssertEqual(statusCode, 400)
        } else {
            XCTFail("Should be clientError type")
        }
        
        if case .httpError(let statusCode) = httpError {
            XCTAssertEqual(statusCode, 500)
        } else {
            XCTFail("Should be httpError type")
        }
    }
    
    func testMakeRequestWithStatusCode299Boundary() async {
        let crlUrl = "https://mock-ca.example.com/boundary-test.crl"
        let mockCrlData = Data("BOUNDARY_CRL_DATA".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData, statusCode: 299)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success(let data):
            XCTAssertEqual(data, mockCrlData, "Should succeed with status 299 (upper boundary)")
        case .failure(let error):
            XCTFail("Should succeed with status 299: \(error)")
        case .none:
            XCTFail("Should return a result")
        }
    }
    
    func testMakeRequestWithNonUTF8ErrorMessage() async {
        let crlUrl = "https://mock-ca.example.com/binary-error.crl"
        
        let binaryErrorData = Data([0xFF, 0xFE, 0xFD, 0xFC, 0xFB])
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: binaryErrorData, statusCode: 400)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let result = await (try? crlClient.makeRequest(for: request))

        switch result {
        case .success:
            XCTFail("Should fail with 400 status")
        case .failure(let error):
            if case .clientError(let message, let statusCode) = error {
                XCTAssertEqual(statusCode, 400, "Should return 400 status code")
                XCTAssertEqual(message, "CRL request failed", "Should use fallback error message when data is not UTF-8")
            } else {
                XCTFail("Should return clientError with fallback message")
            }
        case .none:
            XCTFail("Should return a result")
        }
    }
} 