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

final class TimestampClientTests: XCTestCase {
    
    var timestampClient: TimestampClient!
    var mockHTTPClient: MockHTTPClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        timestampClient = TimestampClient(httpClient: mockHTTPClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        timestampClient = nil
        super.tearDown()
    }
    
    func testMakeRequestWithValidDataAndURL() async {
        let tsqData = "Test timestamp query data".data(using: .utf8)!
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        mockHTTPClient.setMockResponse(for: tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)

        let result = await timestampClient.makeRequest(for: tsqData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertFalse(data.isEmpty, "Response data should not be empty")
            XCTAssertEqual(data, TimestampTestConstants.MockResponses.validTimestampResponse, "Should return exact mocked TSA response - proves MockHTTPClient is used")
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }
    
    func testMakeRequestWithLargeData() async {
        let largeData = Data(repeating: 0x42, count: TimestampTestConstants.TestData.largeDataSize)
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        mockHTTPClient.setMockResponse(for: tsaUrl, data: TimestampTestConstants.MockResponses.largeTimestampResponse)

        let result = await timestampClient.makeRequest(for: largeData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil for large request")
            XCTAssertEqual(data, TimestampTestConstants.MockResponses.largeTimestampResponse, "Should return exact mocked large TSA response")
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }

    func testMakeRequestWithEmptyURL() async {
        let tsqData = "Test data".data(using: .utf8)!
        let emptyUrl = ""

        let result = await timestampClient.makeRequest(for: tsqData, tsaUrl: emptyUrl)

        switch result {
        case .success:
            XCTFail("Should fail with empty URL")
        case .failure(let error):
            XCTAssertEqual(error, ClientError.invalidRequestURL, "Should return invalidRequestURL error")
        }
    }
    
    func testMakeRequestWithUnreachableURL() async {
        let tsqData = "Test data".data(using: .utf8)!
        let unreachableUrl = TimestampTestConstants.URLs.unreachableTsaUrl

        let result = await timestampClient.makeRequest(for: tsqData, tsaUrl: unreachableUrl)

        switch result {
        case .success:
            XCTFail("Should fail with unreachable URL")
        case .failure(let error):
            XCTAssertEqual(error, ClientError.noData, "Should return noData when MockHTTPClient has no response configured")
        }
    }
    
    func testMakeRequestWithEmptyData() async {
        let emptyData = Data()
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        mockHTTPClient.setMockResponse(for: tsaUrl, data: TimestampTestConstants.MockResponses.emptyTimestampResponse)

        let result = await timestampClient.makeRequest(for: emptyData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response should not be nil even with empty request data")
            XCTAssertEqual(data, TimestampTestConstants.MockResponses.emptyTimestampResponse, "Should return exact mocked empty TSA response")
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }
    
    func testMakeRequestHandlesHTTPErrorStatusCodes() async {
        let tsqData = "Test data".data(using: .utf8)!
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        mockHTTPClient.setMockResponse(for: tsaUrl, data: Data("Server Error".utf8), statusCode: 500)

        let result = await timestampClient.makeRequest(for: tsqData, tsaUrl: tsaUrl)

        switch result {
        case .success:
            XCTFail("Should fail with 500 status code")
        case .failure(let error):
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500, "Should return exact mock 500 status code")
            } else {
                XCTFail("Should return httpError with 500 status")
            }
        }
    }
    
    func testMakeRequestIntegrationWithTimestampUtils() async {
        let testData = "Integration test data".data(using: .utf8)!
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        mockHTTPClient.setMockResponse(for: tsaUrl, data: TimestampTestConstants.MockResponses.validTimestampResponse)

        let result = await timestampClient.makeRequest(for: testData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertFalse(data.isEmpty, "Response data should not be empty")
            XCTAssertTrue(data.count > 0, "Response should have content")
            XCTAssertEqual(data, TimestampTestConstants.MockResponses.validTimestampResponse, "Should return exact mocked TSA response - proves MockHTTPClient is used for POST")
            
        case .failure(let error):
            XCTFail("Should succeed with mocked response: \(error)")
        }
    }
} 
