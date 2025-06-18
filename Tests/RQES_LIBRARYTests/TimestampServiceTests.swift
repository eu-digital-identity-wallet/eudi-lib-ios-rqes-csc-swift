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
        let request = createValidTimestampRequest()

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty")
        XCTAssertTrue(response.base64Tsr.count > 0, "Base64 TSR should have content")

        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable")
    }
    
    func testRequestTimestampWithDifferentValidHashes() async throws {
        let testCases = TimestampTestConstants.Hashes.testCases
        
        for testCase in testCases {
            let request = TimestampRequest(
                signedHash: testCase,
                tsaUrl: TimestampTestConstants.URLs.tsaUrl
            )
            
            let response = try await timestampService.requestTimestamp(request: request)
            
            XCTAssertNotNil(response, "Response should not be nil for hash: \(testCase)")
            XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty for hash: \(testCase)")
            
            let decodedData = Data(base64Encoded: response.base64Tsr)
            XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable for hash: \(testCase)")
        }
    }
    
    func testRequestTimestampWithLargeHash() async throws {

        let largeHash = String(repeating: "A", count: TimestampTestConstants.Data.largeDataSize).data(using: .utf8)!.base64EncodedString()
        let request = TimestampRequest(
            signedHash: largeHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil for large hash")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty for large hash")
        
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable for large hash")
    }
    
    // MARK: - Error Tests
    
    func testRequestTimestampWithInvalidBase64Hash() async {

        let request = TimestampRequest(
            signedHash: TimestampTestConstants.Hashes.invalidSignedHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )

        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for invalid base64 hash")
        } catch {
            XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash, "Should throw invalidBase64Hash error")
        }
    }
    
    func testRequestTimestampWithEmptyHash() async {

        let request = TimestampRequest(
            signedHash: "",
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )

        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for empty hash")
        } catch {
            XCTAssertEqual(error as? TimestampUtilsError, .emptyHash, "Should throw emptyHash error")
        }
    }
    
    func testRequestTimestampWithInvalidTsaUrl() async {

        let request = TimestampRequest(
            signedHash: TimestampTestConstants.Hashes.validSignedHash,
            tsaUrl: TimestampTestConstants.URLs.invalidTsaUrl
        )

        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for invalid TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testRequestTimestampWithEmptyTsaUrl() async {

        let request = TimestampRequest(
            signedHash: TimestampTestConstants.Hashes.validSignedHash,
            tsaUrl: ""
        )

        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for empty TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testRequestTimestampWithUnreachableTsaUrl() async {

        let request = TimestampRequest(
            signedHash: TimestampTestConstants.Hashes.validSignedHash,
            tsaUrl: TimestampTestConstants.URLs.unreachableTsaUrl
        )

        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for unreachable TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    // MARK: - Integration Tests
    
    func testTimestampServiceIntegrationWithTimestampUtils() async throws {

        let request = createValidTimestampRequest()

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil")

        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Response should be valid base64")

        let reEncoded = TimestampUtils.encodeTSRToBase64(decodedData!)
        XCTAssertEqual(reEncoded, response.base64Tsr, "Re-encoded TSR should match original")
    }
    
    func testTimestampServiceWithRealisticSignedHash() async throws {
        let realisticSignedHash = TimestampTestConstants.Hashes.realisticSignedHash
        let request = TimestampRequest(
            signedHash: realisticSignedHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil for realistic signed hash")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty")
        
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable")
    }
        
    // MARK: - Helper Methods
    
    private func createValidTimestampRequest() -> TimestampRequest {
        return TimestampRequest(
            signedHash: TimestampTestConstants.Hashes.validSignedHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )
    }
} 
