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

final class TimestampUtilsTests: XCTestCase {
    
    func testBuildTSQWithValidBase64Hash() throws {
        let validBase64Hash = "SGVsbG8gV29ybGQ="
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
    
    func testBuildTSQWithEmptyHash() {
        let emptyHash = ""

        XCTAssertThrowsError(try TimestampUtils.buildTSQ(from: emptyHash)) { error in
            XCTAssertEqual(error as? TimestampUtilsError, .emptyHash)
        }
    }
    
    func testBuildTSQWithDifferentInputs() throws {
        let testCases = [
            "U29tZVRlc3REYXRh",
            "VGVzdFN0cmluZw==",
            "MTIzNDU2Nzg5MA=="
        ]

        for testCase in testCases {
            let tsqData = try TimestampUtils.buildTSQ(from: testCase)
            XCTAssertFalse(tsqData.isEmpty, "TSQ data should not be empty for input: \(testCase)")
        }
    }
    
    func testBuildTSQWithWhitespaceOnlyHash() {
        let whitespaceHash = "   "

        XCTAssertThrowsError(try TimestampUtils.buildTSQ(from: whitespaceHash)) { error in
            XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash, "Whitespace-only string should be invalid base64")
        }
    }
    
    func testBuildTSQWithSingleCharacterHash() {
        let singleCharHash = "A"

        XCTAssertThrowsError(try TimestampUtils.buildTSQ(from: singleCharHash)) { error in
            XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash, "Single character should be invalid base64")
        }
    }
    
    func testBuildTSQWithMalformedBase64Padding() {
        let malformedHashes = [
            "SGVsbG8=A",
            "SGVs!bG8=",
            "!@#$%^&*",
        ]

        for malformedHash in malformedHashes {
            XCTAssertThrowsError(try TimestampUtils.buildTSQ(from: malformedHash)) { error in
                XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash, "Malformed base64 '\(malformedHash)' should be invalid")
            }
        }
    }
    
    func testBuildTSQWithSpecialCharacters() {
        let validBase64WithPlus = "SGVsbG8+V29ybGQ="
        let validBase64WithSlash = "SGVsbG8/V29ybGQ="
        
        XCTAssertNoThrow(try TimestampUtils.buildTSQ(from: validBase64WithPlus))
        XCTAssertNoThrow(try TimestampUtils.buildTSQ(from: validBase64WithSlash))
        
        let invalidBase64 = "Data_Test-"
        XCTAssertThrowsError(try TimestampUtils.buildTSQ(from: invalidBase64)) { error in
            XCTAssertEqual(error as? TimestampUtilsError, .invalidBase64Hash)
        }
    }
    
    func testBuildTSQWithVeryLargeInput() throws {
        let largeInput = String(repeating: "Hello World! ", count: 100)
        let largeBase64 = largeInput.data(using: .utf8)!.base64EncodedString()
        
        let tsqData = try TimestampUtils.buildTSQ(from: largeBase64)
        XCTAssertFalse(tsqData.isEmpty, "TSQ should handle large inputs")
        XCTAssertGreaterThan(tsqData.count, 50, "TSQ for large input should be substantial")
    }
    
    func testBuildTSQGeneratesConsistentOutput() throws {
        let input = "SGVsbG8gV29ybGQ="
        
        let tsq1 = try TimestampUtils.buildTSQ(from: input)
        let tsq2 = try TimestampUtils.buildTSQ(from: input)
        
        XCTAssertEqual(tsq1, tsq2, "Same input should generate identical TSQ")
    }
    
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
    
    func testEncodeTSRToBase64WithBinaryData() {
        let binaryData = Data([0x00, 0xFF, 0x7F, 0x80, 0x01, 0xFE])
        let base64String = TimestampUtils.encodeTSRToBase64(binaryData)
        
        XCTAssertFalse(base64String.isEmpty, "Binary data should encode to base64")
        
        let decodedData = Data(base64Encoded: base64String)
        XCTAssertNotNil(decodedData, "Encoded binary data should decode back")
        XCTAssertEqual(decodedData, binaryData, "Round-trip should preserve binary data")
    }
    
    func testEncodeTSRToBase64WithUnicodeData() {
        let unicodeString = "Hello 🌍 World 测试 данные"
        let unicodeData = unicodeString.data(using: .utf8)!
        let base64String = TimestampUtils.encodeTSRToBase64(unicodeData)
        
        XCTAssertFalse(base64String.isEmpty, "Unicode data should encode to base64")
        
        let decodedData = Data(base64Encoded: base64String)
        XCTAssertNotNil(decodedData, "Encoded unicode data should decode back")
        XCTAssertEqual(decodedData, unicodeData, "Round-trip should preserve unicode data")
    }
    
    func testEncodeTSRToBase64ProducesValidBase64() {
        let testData = "Random test data for validation".data(using: .utf8)!
        let base64String = TimestampUtils.encodeTSRToBase64(testData)
        
        let base64Pattern = "^[A-Za-z0-9+/]*={0,2}$"
        let regex = try! NSRegularExpression(pattern: base64Pattern)
        let range = NSRange(location: 0, length: base64String.utf16.count)
        let matches = regex.firstMatch(in: base64String, options: [], range: range)
        
        XCTAssertNotNil(matches, "Output should be valid base64 format")
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
    
    func testTimestampUtilsErrorEquality() {
        XCTAssertEqual(TimestampUtilsError.emptyHash, TimestampUtilsError.emptyHash)
        XCTAssertEqual(TimestampUtilsError.invalidBase64Hash, TimestampUtilsError.invalidBase64Hash)
        XCTAssertNotEqual(TimestampUtilsError.emptyHash, TimestampUtilsError.invalidBase64Hash)
    }
    
    func testFileUtilsBase64Operations() {
        let validBase64 = FileTestConstants.TestData.sampleBase64
        let decodedData = FileUtils.decodeBase64ToData(base64String: validBase64)
        
        XCTAssertNotNil(decodedData, "Valid base64 should decode successfully")
        XCTAssertEqual(String(data: decodedData!, encoding: .utf8), "Hello World!", "Decoded data should match expected content")
        
        let malformedBase64 = FileTestConstants.TestData.malformedBase64
        let failedDecoding = FileUtils.decodeBase64ToData(base64String: malformedBase64)
        XCTAssertNil(failedDecoding, "Malformed base64 should return nil")
        
        let emptyDecoding = FileUtils.decodeBase64ToData(base64String: "")
        XCTAssertNotNil(emptyDecoding, "Empty string should return empty data")
        XCTAssertTrue(emptyDecoding!.isEmpty, "Empty string should decode to empty data")
    }
    
    func testFileUtilsBinaryDataHandling() {
        let binaryData = FileTestConstants.TestData.binaryData
        let base64Encoded = binaryData.base64EncodedString()
        let decodedBack = FileUtils.decodeBase64ToData(base64String: base64Encoded)
        
        XCTAssertNotNil(decodedBack, "Binary data round-trip should work")
        XCTAssertEqual(decodedBack, binaryData, "Binary data should round-trip correctly")
    }
    
    func testJSONUtilsStringifyValidObject() {
        struct TestObject: Codable {
            let name: String
            let age: Int
            let active: Bool
        }
        
        let testObj = TestObject(name: "Test User", age: 30, active: true)
        let jsonString = JSONUtils.stringify(testObj)
        
        XCTAssertNotNil(jsonString, "Valid object should stringify successfully")
        XCTAssertTrue(jsonString!.contains("Test User"), "JSON should contain expected data")
        XCTAssertTrue(jsonString!.contains("30"), "JSON should contain age")
        XCTAssertTrue(jsonString!.contains("true"), "JSON should contain boolean value")
    }
    
    func testJSONUtilsStringifyEmptyObject() {
        struct EmptyObject: Codable {}
        
        let emptyObj = EmptyObject()
        let jsonString = JSONUtils.stringify(emptyObj)
        
        XCTAssertNotNil(jsonString, "Empty object should stringify successfully")
        XCTAssertEqual(jsonString, "{}", "Empty object should produce empty JSON")
    }
    
    func testJSONUtilsStringifyArrays() {
        let stringArray = ["hello", "world"]
        let numberArray = [1, 2, 3, 4, 5]
        
        let stringArrayJSON = JSONUtils.stringify(stringArray)
        let numberArrayJSON = JSONUtils.stringify(numberArray)
        
        XCTAssertNotNil(stringArrayJSON, "String array should stringify")
        XCTAssertNotNil(numberArrayJSON, "Number array should stringify")
        
        XCTAssertTrue(stringArrayJSON!.contains("hello"), "String array JSON should contain elements")
        XCTAssertTrue(numberArrayJSON!.contains("1"), "Number array JSON should contain elements")
    }
    
    func testJSONUtilsStringifySpecialCharacters() {
        struct SpecialCharObject: Codable {
            let unicode: String
            let quotes: String
            let newlines: String
        }
        
        let specialObj = SpecialCharObject(
            unicode: "Hello 🌍 World",
            quotes: "He said \"Hello\"",
            newlines: "Line 1\nLine 2"
        )
        
        let jsonString = JSONUtils.stringify(specialObj)
        
        XCTAssertNotNil(jsonString, "Object with special characters should stringify")
        XCTAssertTrue(jsonString!.contains("🌍"), "Unicode should be preserved")
        XCTAssertTrue(jsonString!.contains("\\\""), "Quotes should be escaped")
        XCTAssertTrue(jsonString!.contains("\\n"), "Newlines should be escaped")
    }
    
    func testTimestampUtilsWithRealWorldData() throws {
        let realisticHashData = "ZjNkYmIwMzk5ODM5ODY5ZGE2ZjY4M2JjZWQyNDczNDQ="
        let tsqData = try TimestampUtils.buildTSQ(from: realisticHashData)
        
        XCTAssertFalse(tsqData.isEmpty, "TSQ should be generated for realistic data")
        XCTAssertGreaterThan(tsqData.count, 30, "TSQ should have substantial length")
        
        let encodedTSQ = TimestampUtils.encodeTSRToBase64(tsqData)
        XCTAssertFalse(encodedTSQ.isEmpty, "TSQ should encode to base64")
        
        let decodedTSQ = Data(base64Encoded: encodedTSQ)
        XCTAssertNotNil(decodedTSQ, "Encoded TSQ should decode back")
        XCTAssertEqual(decodedTSQ, tsqData, "Round trip should preserve data")
    }

    func testTLVEncodingShortForm() {
        let tag: UInt8 = 0x30
        let value = Data(repeating: 0x01, count: 10)
        let expectedTLV = Data([0x30, 0x0a]) + value
        let tlvData = Data.tlv(tag, value)
        XCTAssertEqual(tlvData, expectedTLV, "TLV short form encoding failed")
    }

    func testTLVEncodingLongFormSingleByteLength() {
        let tag: UInt8 = 0x30
        let value = Data(repeating: 0x02, count: 130)
        let expectedTLV = Data([0x30, 0x81, 0x82]) + value
        let tlvData = Data.tlv(tag, value)
        XCTAssertEqual(tlvData, expectedTLV, "TLV long form single-byte length encoding failed")
    }

    func testTLVEncodingLongFormMultiByteLength() {
        let tag: UInt8 = 0x30
        let value = Data(repeating: 0x03, count: 300)
        let expectedLengthBytes = Data([0x82, 0x01, 0x2c])
        let expectedTLV = Data([tag]) + expectedLengthBytes + value
        let tlvData = Data.tlv(tag, value)
        XCTAssertEqual(tlvData, expectedTLV, "TLV long form multi-byte length encoding failed")
    }
    
    func testTLVEncodingWithEmptyValue() {
        let tag: UInt8 = 0x04
        let value = Data()
        let expectedTLV = Data([0x04, 0x00])
        let tlvData = Data.tlv(tag, value)
        XCTAssertEqual(tlvData, expectedTLV, "TLV encoding with empty value failed")
    }
} 
