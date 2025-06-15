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

final class TimestampUtilsTests: XCTestCase {
    
    // MARK: - buildTSQ Tests
    
    func testBuildTSQWithValidBase64Hash() throws {
        let validBase64Hash = "SGVsbG8gV29ybGQ=" // "Hello World" in base64
        let tsqData = try TimestampUtils.buildTSQ(from: validBase64Hash)

        XCTAssertFalse(tsqData.isEmpty, "TSQ data should not be empty")
        XCTAssertGreaterThan(tsqData.count, 0, "TSQ data should have content")
    }
    
    func testBuildTSQWithInvalidBase64Hash() {
        let invalidBase64Hash = "InvalidBase64!@#"

        XCTAssertThrowsError(try TimestampUtils.buildTSQ(from: invalidBase64Hash)) { error in
            XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash)
        }
    }
    
    func testBuildTSQWithDifferentInputs() throws {
        let testCases = [
            "U29tZVRlc3REYXRh", // "SomeTestData" in base64
            "VGVzdFN0cmluZw==",   // "TestString" in base64
            "MTIzNDU2Nzg5MA=="    // "1234567890" in base64
        ]

        for testCase in testCases {
            let tsqData = try TimestampUtils.buildTSQ(from: testCase)
            XCTAssertFalse(tsqData.isEmpty, "TSQ data should not be empty for input: \(testCase)")
        }
    }
    
    // MARK: - encodeTSRToBase64 Tests
    
    func testEncodeTSRToBase64() {
        let testData = "Test TSR Data".data(using: .utf8)!
        let base64String = TimestampUtils.encodeTSRToBase64(testData)

        XCTAssertFalse(base64String.isEmpty, "Base64 string should not be empty")
        XCTAssertTrue(base64String.count > 0, "Base64 string should have content")

        let decodedData = Data(base64Encoded: base64String)
        XCTAssertNotNil(decodedData, "Base64 string should be valid and decodable")
        XCTAssertEqual(decodedData, testData, "Decoded data should match original data")
    }
    
    func testEncodeTSRToBase64WithEmptyData() {
        let emptyData = Data()
        let base64String = TimestampUtils.encodeTSRToBase64(emptyData)
        XCTAssertEqual(base64String, "", "Empty data should result in empty base64 string")
    }
    
    func testEncodeTSRToBase64WithLargeData() {
        let largeData = Data(repeating: 0x42, count: 1000)
        let base64String = TimestampUtils.encodeTSRToBase64(largeData)
        XCTAssertFalse(base64String.isEmpty, "Base64 string should not be empty")

        let decodedData = Data(base64Encoded: base64String)
        XCTAssertNotNil(decodedData, "Base64 string should be valid and decodable")
        XCTAssertEqual(decodedData, largeData, "Decoded data should match original data")
    }
    
    func testBuildTSQAndEncodeTSRIntegration() throws {
        let validBase64Hash = "SGVsbG8gV29ybGQ="

        let tsqData = try TimestampUtils.buildTSQ(from: validBase64Hash)
        let encodedTSR = TimestampUtils.encodeTSRToBase64(tsqData)

        XCTAssertFalse(tsqData.isEmpty, "TSQ data should not be empty")
        XCTAssertFalse(encodedTSR.isEmpty, "Encoded TSR should not be empty")

        let decodedData = Data(base64Encoded: encodedTSR)
        XCTAssertNotNil(decodedData, "Encoded TSR should be valid base64")
        XCTAssertEqual(decodedData, tsqData, "Decoded TSR should match original TSQ data")
    }
} 
