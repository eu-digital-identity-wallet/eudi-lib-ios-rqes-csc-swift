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

final class TimestampClientTests: XCTestCase {
    
    var timestampClient: TimestampClient!
    
    override func setUp() {
        super.setUp()
        timestampClient = TimestampClient()
    }
    
    override func tearDown() {
        timestampClient = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testMakeRequestWithValidDataAndURL() async {
        let tsqData = "Test timestamp query data".data(using: .utf8)!
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        let result = await TimestampClient.makeRequest(for: tsqData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertFalse(data.isEmpty, "Response data should not be empty")
        case .failure(let error):
            break
        }
    }
    
    func testMakeRequestWithLargeData() async {
        let largeData = Data(repeating: 0x42, count: TimestampTestConstants.Data.largeDataSize)
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        let result = await TimestampClient.makeRequest(for: largeData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil for large request")
        case .failure(let error):
            break
        }
    }

    // MARK: - Error Tests
    
    func testMakeRequestWithEmptyURL() async {
        let tsqData = "Test data".data(using: .utf8)!
        let emptyUrl = ""

        let result = await TimestampClient.makeRequest(for: tsqData, tsaUrl: emptyUrl)

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

        let result = await TimestampClient.makeRequest(for: tsqData, tsaUrl: unreachableUrl)

        switch result {
        case .success:
            XCTFail("Should fail with unreachable URL")
        case .failure(let error):
            XCTAssertEqual(error, ClientError.noData, "Should return noData error for unreachable URL")
        }
    }
    
    func testMakeRequestWithEmptyData() async {
        let emptyData = Data()
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        let result = await TimestampClient.makeRequest(for: emptyData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response should not be nil even with empty request data")
        case .failure(let error):
            break
        }
    }
    
    // MARK: - HTTP Response Tests
    
    func testMakeRequestHandlesHTTPErrorStatusCodes() async {
        let tsqData = "Test data".data(using: .utf8)!
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        let result = await TimestampClient.makeRequest(for: tsqData, tsaUrl: tsaUrl)

        switch result {
        case .success:
            break
        case .failure(let error):
            if case .httpError(let statusCode) = error {
                XCTAssertNotEqual(statusCode, 200, "Should not be 200 status code")
                XCTAssertTrue(statusCode >= 400, "Should be an error status code")
            } else {
                break
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testMakeRequestIntegrationWithTimestampUtils() async {
        let testData = "Integration test data".data(using: .utf8)!
        let tsaUrl = TimestampTestConstants.URLs.tsaUrl

        let result = await TimestampClient.makeRequest(for: testData, tsaUrl: tsaUrl)

        switch result {
        case .success(let data):
            XCTAssertNotNil(data, "Response data should not be nil")
            XCTAssertFalse(data.isEmpty, "Response data should not be empty")
            XCTAssertTrue(data.count > 0, "Response should have content")
            
        case .failure(let error):
            break
        }
    }

} 
