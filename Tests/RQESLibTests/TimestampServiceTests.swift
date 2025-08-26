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

final class TimestampServiceTests: XCTestCase {
    
    var timestampService: TimestampService!
    var mockHTTPClient: MockHTTPClient!
    var timestampClient: TimestampClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        timestampClient = TimestampClient(httpClient: mockHTTPClient)
        timestampService = TimestampService(timestampClient: timestampClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        timestampClient = nil
        timestampService = nil
        super.tearDown()
    }
    
    func testRequestTimestampWithValidRequest() async throws {
        let request = createValidTimestampRequest()
        
        let expectedBase64 = TimestampUtils.encodeTSRToBase64(TimestampTestConstants.MockResponses.validTimestampResponse)

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty")
        
        XCTAssertEqual(response.base64Tsr, expectedBase64, "Response should contain properly encoded mock TSR data")

        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable")
        XCTAssertEqual(decodedData, TimestampTestConstants.MockResponses.validTimestampResponse, "Decoded data should match original mock data")
    }
    
    func testRequestTimestampWithDifferentValidHashes() async throws {
        let testCases = TimestampTestConstants.Hashes.testCases
        let expectedBase64 = TimestampUtils.encodeTSRToBase64(TimestampTestConstants.MockResponses.validTimestampResponse)
        
        for testCase in testCases {
            let request = TimestampRequest(
                hashToTimestamp: testCase,
                tsaUrl: TimestampTestConstants.URLs.tsaUrl
            )
            
            mockHTTPClient.setMockResponse(for: TimestampTestConstants.URLs.tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)
            
            let response = try await timestampService.requestTimestamp(request: request)
            
            XCTAssertNotNil(response, "Response should not be nil for hash: \(testCase)")
            XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty for hash: \(testCase)")
            
            XCTAssertEqual(response.base64Tsr, expectedBase64, "Response should contain properly encoded mock TSR data for hash: \(testCase)")
            
            let decodedData = Data(base64Encoded: response.base64Tsr)
            XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable for hash: \(testCase)")
            XCTAssertEqual(decodedData, TimestampTestConstants.MockResponses.validTimestampResponse, "Decoded data should match original mock data")
        }
    }
    
    func testRequestTimestampWithLargeHash() async throws {
        let largeHash = String(repeating: "A", count: TimestampTestConstants.TestData.largeDataSize).data(using: .utf8)!.base64EncodedString()
        let request = TimestampRequest(
            hashToTimestamp: largeHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )

        mockHTTPClient.setMockResponse(for: TimestampTestConstants.URLs.tsaUrl, data: TimestampTestConstants.MockResponses.largeTimestampResponse)
        let expectedBase64 = TimestampUtils.encodeTSRToBase64(TimestampTestConstants.MockResponses.largeTimestampResponse)

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil for large hash")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty for large hash")
        
        XCTAssertEqual(response.base64Tsr, expectedBase64, "Response should contain properly encoded large mock TSR data")
        
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable for large hash")
        XCTAssertEqual(decodedData, TimestampTestConstants.MockResponses.largeTimestampResponse, "Decoded data should match original large mock data")
    }
    
    func testRequestTimestampWithInvalidBase64Hash() async {
        let request = TimestampRequest(
            hashToTimestamp: TimestampTestConstants.Hashes.invalidSignedHash,
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
            hashToTimestamp: "",
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
            hashToTimestamp: TimestampTestConstants.Hashes.validSignedHash,
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
            hashToTimestamp: TimestampTestConstants.Hashes.validSignedHash,
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
            hashToTimestamp: TimestampTestConstants.Hashes.validSignedHash,
            tsaUrl: TimestampTestConstants.URLs.unreachableTsaUrl
        )

        do {
            _ = try await timestampService.requestTimestamp(request: request)
            XCTFail("Should throw error for unreachable TSA URL")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError")
        }
    }
    
    func testTimestampServiceIntegrationWithTimestampUtils() async throws {
        let request = createValidTimestampRequest()
        let expectedBase64 = TimestampUtils.encodeTSRToBase64(TimestampTestConstants.MockResponses.validTimestampResponse)

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil")

        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Response should be valid base64")
        XCTAssertEqual(decodedData, TimestampTestConstants.MockResponses.validTimestampResponse, "Decoded data should match mock data")

        let reEncoded = TimestampUtils.encodeTSRToBase64(decodedData!)
        XCTAssertEqual(reEncoded, response.base64Tsr, "Re-encoded TSR should match original")
        XCTAssertEqual(response.base64Tsr, expectedBase64, "Response should match expected encoding")
    }
    
    func testTimestampServiceWithRealisticSignedHash() async throws {
        let realisticSignedHash = TimestampTestConstants.Hashes.realisticSignedHash
        let request = TimestampRequest(
            hashToTimestamp: realisticSignedHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )

        mockHTTPClient.setMockResponse(for: TimestampTestConstants.URLs.tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)
        let expectedBase64 = TimestampUtils.encodeTSRToBase64(TimestampTestConstants.MockResponses.validTimestampResponse)

        let response = try await timestampService.requestTimestamp(request: request)

        XCTAssertNotNil(response, "Response should not be nil for realistic signed hash")
        XCTAssertFalse(response.base64Tsr.isEmpty, "Base64 TSR should not be empty")
        
        XCTAssertEqual(response.base64Tsr, expectedBase64, "Response should contain properly encoded mock TSR data")
        
        let decodedData = Data(base64Encoded: response.base64Tsr)
        XCTAssertNotNil(decodedData, "Base64 TSR should be valid and decodable")
        XCTAssertEqual(decodedData, TimestampTestConstants.MockResponses.validTimestampResponse, "Decoded data should match original mock data")
    }
    
    func testRequestTimestampSuccess() async throws {
        let mockHttpClient = MockHTTPClient()
        mockHttpClient.setMockResponse(for: TimestampTestConstants.URLs.tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)
        let timestampClient = TimestampClient(httpClient: mockHttpClient)
        let timestampService = TimestampService(timestampClient: timestampClient)
        
        let request = TimestampRequest(hashToTimestamp: TimestampTestConstants.Hashes.validSignedHash, tsaUrl: TimestampTestConstants.URLs.tsaUrl)
        let response = try await timestampService.requestTimestamp(request: request)
        
        XCTAssertEqual(response.base64Tsr, TimestampTestConstants.MockResponses.validTimestampResponse.base64EncodedString())
    }
    
    func testRequestDocTimestampSuccess() async throws {
        let mockHttpClient = MockHTTPClient()
        mockHttpClient.setMockResponse(for: TimestampTestConstants.URLs.tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)
        let timestampClient = TimestampClient(httpClient: mockHttpClient)
        let timestampService = TimestampService(timestampClient: timestampClient)
        
        let request = TimestampRequest(hashToTimestamp: TimestampTestConstants.Hashes.validSignedHash, tsaUrl: TimestampTestConstants.URLs.tsaUrl)
        let response = try await timestampService.requestDocTimestamp(request: request)
        
        XCTAssertEqual(response.base64Tsr, TimestampTestConstants.MockResponses.validTimestampResponse.base64EncodedString())
    }
        
    private func createValidTimestampRequest() -> TimestampRequest {
        mockHTTPClient.setMockResponse(for: TimestampTestConstants.URLs.tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)
        
        return TimestampRequest(
            hashToTimestamp: TimestampTestConstants.Hashes.validSignedHash,
            tsaUrl: TimestampTestConstants.URLs.tsaUrl
        )
    }
} 
