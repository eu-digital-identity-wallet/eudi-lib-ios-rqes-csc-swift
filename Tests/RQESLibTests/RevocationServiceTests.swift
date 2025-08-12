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

final class RevocationServiceTests: XCTestCase {
    
    var revocationService: RevocationService!
    var mockHTTPClient: MockHTTPClient!
    var crlClient: CrlClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        crlClient = CrlClient(httpClient: mockHTTPClient)
        revocationService = RevocationService(crlClient: crlClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        crlClient = nil
        revocationService = nil
        super.tearDown()
    }
    
    func testGetCrlDataWithValidRequest() async throws {
        let crlUrl = "https://mock-ca.example.com/ca.crl"
        let mockCrlData = Data("MOCK_CRL_BINARY_DATA_FOR_TESTING".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)

        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Base64 CRL should not be empty")
        XCTAssertTrue(response.crlInfoBase64.count > 0, "Base64 CRL should have content")

        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Base64 CRL should be valid and decodable")
        XCTAssertEqual(decodedData, mockCrlData, "Decoded data should exactly match mock data - proves MockHTTPClient is used")
        
        let decodedString = String(data: decodedData!, encoding: .utf8)
        XCTAssertEqual(decodedString, "MOCK_CRL_BINARY_DATA_FOR_TESTING", "Should return exact mock string content")
    }
    
    func testGetCrlDataWithRealCrlUrl() async throws {
        let crlUrl = "https://mock-ca.example.com/real-ca.crl"
        let mockCrlData = Data("MOCK_REAL_CRL_DATA_FOR_TESTING".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)
        
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Base64 CRL should not be empty")
        
        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Base64 CRL should be valid and decodable")
        XCTAssertEqual(decodedData, mockCrlData, "Decoded data should match mock data")
    }
    
    func testGetCrlDataWithAnotherValidUrl() async throws {
        let crlUrl = "https://mock-ca.example.com/another-ca.crl"
        let mockCrlData = Data("MOCK_ANOTHER_CRL_DATA_FOR_TESTING".utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)
        XCTAssertNotNil(response, "Response should not be nil for HTTPS URL")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Base64 CRL should not be empty")
        
        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Base64 CRL should be valid and decodable")
        XCTAssertEqual(decodedData, mockCrlData, "Decoded data should match mock data")
    }
    
    func testGetCrlDataWithInvalidUrl() async {
        let request = CrlRequest(crlUrl: "invalid-url")

        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for invalid URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testGetCrlDataWithEmptyUrl() async {
        let request = CrlRequest(crlUrl: "")

        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for empty URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testGetCrlDataWithUnreachableUrl() async {
        let crlUrl = "https://unreachable-crl-server.com/ca.crl"
        
        let request = CrlRequest(crlUrl: crlUrl)

        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for unreachable URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testGetCrlDataWithNonExistentPath() async {
        let crlUrl = "https://mock-ca.example.com/not-found.crl"
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data(), statusCode: 404)
        
        let request = CrlRequest(crlUrl: crlUrl)

        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for 404 status")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
            if case .clientError(_, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 404, "Should be 404 error")
            }
        }
    }
    
    func testGetCrlDataWithServerError() async {
        let crlUrl = "https://mock-ca.example.com/server-error.crl"
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Server Error".utf8), statusCode: 500)
        
        let request = CrlRequest(crlUrl: crlUrl)

        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for 500 status")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
            if case .clientError(let message, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 500, "Should return exact mock 500 status")
                XCTAssertEqual(message, "Server Error", "Should return exact mock error message")
            } else {
                XCTFail("Should return clientError with 500 status and message")
            }
        }
    }
    
    func testGetCrlDataWithUnauthorizedAccess() async {
        let crlUrl = "https://mock-ca.example.com/unauthorized.crl"
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Unauthorized".utf8), statusCode: 401)
        
        let request = CrlRequest(crlUrl: crlUrl)

        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for 401 status")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
            if case .clientError(_, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 401, "Should be 401 error")
            }
        }
    }
    
    func testRevocationServiceIntegrationWithCrlClient() async throws {
        let request = createValidCrlRequest()

        let response = try await revocationService.getCrlData(request: request)

        XCTAssertNotNil(response, "Response should not be nil")

        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Response should be valid base64")

        let reEncoded = decodedData!.base64EncodedString()
        XCTAssertEqual(reEncoded, response.crlInfoBase64, "Re-encoded CRL should match original")
    }
    
    func testRevocationServiceWithRealCrlEndpoint() async throws {
        let crlUrl = "https://mock-ca.example.com/substantial-crl.crl"
        let mockCrlData = Data(String(repeating: "MOCK_SUBSTANTIAL_CRL_DATA_", count: 10).utf8)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)

        XCTAssertNotNil(response, "Response should not be nil for real CRL endpoint")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Base64 CRL should not be empty")
        
        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Base64 CRL should be valid and decodable")
        XCTAssertTrue(decodedData!.count > 100, "CRL data should be substantial")
        XCTAssertEqual(decodedData, mockCrlData, "Decoded data should match mock data")
    }
    
    func testRevocationServiceBase64Encoding() async throws {
        let request = createValidCrlRequest()

        let response = try await revocationService.getCrlData(request: request)

        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Base64 CRL should not be empty")
        
        let base64Pattern = "^[A-Za-z0-9+/]*={0,2}$"
        let regex = try NSRegularExpression(pattern: base64Pattern)
        let range = NSRange(location: 0, length: response.crlInfoBase64.utf16.count)
        let matches = regex.firstMatch(in: response.crlInfoBase64, options: [], range: range)
        
        XCTAssertNotNil(matches, "Response should contain valid base64 format")
    }
    
    func testRevocationServiceDataConsistency() async throws {
        let request = createValidCrlRequest()

        let response1 = try await revocationService.getCrlData(request: request)
        let response2 = try await revocationService.getCrlData(request: request)

        XCTAssertEqual(response1.crlInfoBase64, response2.crlInfoBase64, "Multiple calls should return consistent data")
    }
    
    func testGetCrlDataWithMalformedUrl() async {
        let malformedUrls = [
            "htp://invalid-protocol.com/crl",
            "https://",
            "://missing-protocol.com/crl",
            "https://valid.com:99999/crl",
        ]
        
        for malformedUrl in malformedUrls {
            let request = CrlRequest(crlUrl: malformedUrl)
            
            do {
                _ = try await revocationService.getCrlData(request: request)
                XCTFail("Should throw error for malformed URL: \(malformedUrl)")
            } catch {
                XCTAssertTrue(error is ClientError, "Should throw ClientError for malformed URL: \(malformedUrl)")
            }
        }
    }
    
    func testGetCrlDataWithDifferentHttpErrorCodes() async {
        let errorCodes = [400, 401, 403, 404, 500, 502, 503]
        
        for statusCode in errorCodes {
            let crlUrl = "https://mock-ca.example.com/error-\(statusCode).crl"
            mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Error \(statusCode)".utf8), statusCode: statusCode)
            
            let request = CrlRequest(crlUrl: crlUrl)
            
            do {
                _ = try await revocationService.getCrlData(request: request)
                XCTFail("Should throw error for HTTP \(statusCode)")
            } catch {
                XCTAssertTrue(error is ClientError, "Should throw ClientError for HTTP \(statusCode)")
                if case .clientError(_, let returnedStatusCode) = error as? ClientError {
                    XCTAssertEqual(returnedStatusCode, statusCode, "Should return correct status code")
                }
            }
        }
    }
    
    func testGetCrlDataWithNetworkTimeoutSimulation() async {
        let crlUrl = "https://mock-ca.example.com/timeout.crl"
        
        mockHTTPClient.setMockError(URLError(.timedOut))
        
        let request = CrlRequest(crlUrl: crlUrl)
        
        do {
            _ = try await revocationService.getCrlData(request: request)
            XCTFail("Should throw error for network timeout")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError for timeout")
        }
    }
    
    func testGetCrlDataWithLargeResponse() async throws {
        let crlUrl = "https://mock-ca.example.com/large-crl.crl"
        let largeMockData = Data(repeating: 0x42, count: 50000)
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: largeMockData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)
        
        XCTAssertNotNil(response, "Should handle large responses")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Base64 should not be empty")
        
        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Large response should be valid base64")
        XCTAssertEqual(decodedData, largeMockData, "Large data should round-trip correctly")
    }
    
    func testGetCrlDataWithEmptyResponse() async throws {
        let crlUrl = "https://mock-ca.example.com/empty-crl.crl"
        mockHTTPClient.setMockResponse(for: crlUrl, data: Data())
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)
        
        XCTAssertNotNil(response, "Should handle empty responses")
        XCTAssertEqual(response.crlInfoBase64, "", "Empty data should result in empty base64")
    }
    
    func testGetCrlDataWithBinaryContent() async throws {
        let crlUrl = "https://mock-ca.example.com/binary-crl.crl"
        let binaryData = Data([0x00, 0x01, 0xFF, 0x7F, 0x80, 0xFE, 0x42, 0x24])
        
        mockHTTPClient.setMockResponse(for: crlUrl, data: binaryData)
        
        let request = CrlRequest(crlUrl: crlUrl)
        let response = try await revocationService.getCrlData(request: request)
        
        XCTAssertNotNil(response, "Should handle binary content")
        XCTAssertFalse(response.crlInfoBase64.isEmpty, "Binary data should encode to base64")
        
        let decodedData = Data(base64Encoded: response.crlInfoBase64)
        XCTAssertNotNil(decodedData, "Binary data should decode correctly")
        XCTAssertEqual(decodedData, binaryData, "Binary data should round-trip correctly")
    }
    
    func testGetCrlDataHandlesRedirectStatusCodes() async {
        let redirectCodes = [301, 302, 307, 308]
        
        for statusCode in redirectCodes {
            let crlUrl = "https://mock-ca.example.com/redirect-\(statusCode).crl"
            mockHTTPClient.setMockResponse(for: crlUrl, data: Data("Redirect \(statusCode)".utf8), statusCode: statusCode)
            
            let request = CrlRequest(crlUrl: crlUrl)
            
            do {
                _ = try await revocationService.getCrlData(request: request)
                XCTFail("Should handle redirect \(statusCode) as error")
            } catch {
                XCTAssertTrue(error is ClientError, "Should treat redirect as error for status \(statusCode)")
            }
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
        
    private func createValidCrlRequest() -> CrlRequest {
        let crlUrl = "https://mock-ca.example.com/default.crl"
        let mockCrlData = Data("DEFAULT_MOCK_CRL_DATA".utf8)
        mockHTTPClient.setMockResponse(for: crlUrl, data: mockCrlData)
        return CrlRequest(crlUrl: crlUrl)
    }
    
    func testGetOcspDataSuccess() async throws {
        let mockHttpClient = MockHTTPClient()
        mockHttpClient.setMockResponse(for: OcspTestConstants.URLs.ocspUrl, data: OcspTestConstants.MockData.successResponse)
        let revocationService = RevocationService(ocspClient: OcspClient(httpClient: mockHttpClient))
        
        let request = OcspRequest(ocspUrl: OcspTestConstants.URLs.ocspUrl, ocspRequest: OcspTestConstants.MockData.request)
        let response = try await revocationService.getOcspData(request: request)
        
        XCTAssertEqual(response.ocspInfoBase64, OcspTestConstants.MockData.successResponse.base64EncodedString())
    }
} 
