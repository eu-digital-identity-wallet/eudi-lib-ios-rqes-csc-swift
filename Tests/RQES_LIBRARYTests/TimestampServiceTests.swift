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
@testable import RQES_LIBRARY

final class TimestampServiceTests: XCTestCase {
    
    var timestampService: TimestampService!
    
    override func setUp() {
        super.setUp()
        timestampService = TimestampService()
    }
    
    override func tearDown() {
        timestampService = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testRequestTimestampWithValidRequest() async throws {
        // Given
        let request = createValidTimestampRequest()
        
        // When
        let response = try await timestampService.requestTimestamp(request: request)
        
        // Then
        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty")
        XCTAssertTrue(response.base64Tsr.count > 0, "Base64 TSR should have content")
        
        // Verify the response is valid base64
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable")
    }
    
    func testRequestTimestampWithDifferentValidHashes() async throws {
        let testCases = [
            "SGVsbG8gV29ybGQ=", // "Hello World" in base64
            "U29tZVRlc3REYXRh", // "SomeTestData" in base64
            "VGVzdFN0cmluZw==", // "TestString" in base64
            "MTIzNDU2Nzg5MA=="  // "1234567890" in base64
        ]
        
        for testCase in testCases {
            let request = TimestampRequest(
                signedHash: testCase,
                tsaUrl: TestConstants.tsaUrl
            )
            
            let response = try await timestampService.requestTimestamp(request: request)
            
            XCTAssertNotNil(response, "Response should not be nil for hash: \(testCase)")
            XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty for hash: \(testCase)")
            
            let decodedData = Data(base64Encoded: response.base64Tsr)
            XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable for hash: \(testCase)")
        }
    }
    
    func testRequestTimestampWithLargeHash() async throws {
        // Given
        let largeHash = String(repeating: "A", count: 1000).data(using: .utf8)!.base64EncodedString()
        let request = TimestampRequest(
            signedHash: largeHash,
            tsaUrl: TestConstants.tsaUrl
        )
        
        // When
        let response = try await timestampService.requestTimestamp(request: request)
        
        // Then
        XCTAssertNotNil(response, "Response should not be nil for large hash")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty for large hash")
        
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable for large hash")
    }
    
    // MARK: - Error Tests
    
    func testRequestTimestampWithInvalidBase64Hash() async {
        // Given
        let request = TimestampRequest(
            signedHash: "InvalidBase64!@#",
            tsaUrl: TestConstants.tsaUrl
        )
        
        // When & Then
        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for invalid base64 hash")
        } catch {
            XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash, "Should throw invalidBase64Hash error")
        }
    }
    
    func testRequestTimestampWithEmptyHash() async {
        // Given
        let request = TimestampRequest(
            signedHash: "",
            tsaUrl: TestConstants.tsaUrl
        )
        
        // When & Then
        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for empty hash")
        } catch {
            XCTAssertEqual(error as? TimestampUtilsError, .emptyHash, "Should throw emptyHash error")
        }
    }
    
    func testRequestTimestampWithInvalidTsaUrl() async {
        // Given
        let request = TimestampRequest(
            signedHash: TestConstants.validSignedHash,
            tsaUrl: "invalid-url"
        )
        
        // When & Then
        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for invalid TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testRequestTimestampWithEmptyTsaUrl() async {
        // Given
        let request = TimestampRequest(
            signedHash: TestConstants.validSignedHash,
            tsaUrl: ""
        )
        
        // When & Then
        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for empty TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testRequestTimestampWithUnreachableTsaUrl() async {
        // Given
        let request = TimestampRequest(
            signedHash: TestConstants.validSignedHash,
            tsaUrl: "https://unreachable-tsa-server.com/timestamp"
        )
        
        // When & Then
        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for unreachable TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    // MARK: - Integration Tests
    
    func testTimestampServiceIntegrationWithTimestampUtils() async throws {
        // Given
        let request = createValidTimestampRequest()
        
        // When
        let response = try await timestampService.requestTimestamp(request: request)
        
        // Then
        XCTAssertNotNil(response, "Response should not be nil")
        
        // Verify the response can be processed by TimestampUtils
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Response should be valid base64")
        
        // Verify the encoded TSR matches the original data
        let reEncoded = TimestampUtils.encodeTSRToBase64(decodedData!)
        XCTAssertEqual(reEncoded, response.base64Tsr, "Re-encoded TSR should match original")
    }
    
    func testTimestampServiceWithRealisticSignedHash() async throws {
        // Given - Using a realistic signed hash from the PoDoFo integration test
        let realisticSignedHash = "MEUCIQCpel09QAFtK/fPUvn+Nhx4VPH7Fm+vspv/UXluxXSKBAIge68SlU0JHVJCbKABh1GpNEiU2gD9sMVaWtLBv3Vb7kE="
        let request = TimestampRequest(
            signedHash: realisticSignedHash,
            tsaUrl: TestConstants.tsaUrl
        )
        
        // When
        let response = try await timestampService.requestTimestamp(request: request)
        
        // Then
        XCTAssertNotNil(response, "Response should not be nil for realistic signed hash")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty")
        
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable")
    }
        
    // MARK: - Helper Methods
    
    private func createValidTimestampRequest() -> TimestampRequest {
        return TimestampRequest(
            signedHash: TestConstants.validSignedHash,
            tsaUrl: TestConstants.tsaUrl
        )
    }
}

// MARK: - Test Constants

private enum TestConstants {
    static let validSignedHash = "SGVsbG8gV29ybGQ=" // "Hello World" in base64
    static let invalidSignedHash = "InvalidBase64!@#"
    static let tsaUrl = "https://freetsa.org/tsr" // Example TSA URL
    static let testDataString = "Test data for timestamping"
    static let largeDataByte: UInt8 = 0x42
    static let largeDataSize = 1000
    static let certificate = "MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
    static let chainCertificate = "MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
} 
