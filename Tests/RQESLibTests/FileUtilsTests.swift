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

final class FileUtilsTests: XCTestCase {
    
    private var tempFiles: [URL] = []
    
    override func setUp() {
        super.setUp()
        tempFiles = []
    }
    
    override func tearDown() {
        for fileURL in tempFiles {
            try? FileManager.default.removeItem(at: fileURL)
        }
        tempFiles.removeAll()
        super.tearDown()
    }
    
    private func addTempFile(_ url: URL) {
        tempFiles.append(url)
    }
    
    func testGetFileURLWithValidSamplePDF() {
        let result = FileUtils.getFileURL(fileNameWithExtension: FileTestConstants.Paths.samplePDFFullName)
        
        XCTAssertNotNil(result, "Should return URL for existing sample.pdf")
        XCTAssertTrue(result?.lastPathComponent == FileTestConstants.Paths.samplePDFFullName, "Should return correct file name")
        XCTAssertTrue(result?.path.contains("Documents") == true, "Should be in Documents folder")
    }
    
    func testGetFileURLWithNonExistentFile() {
        let result = FileUtils.getFileURL(fileNameWithExtension: FileTestConstants.Paths.nonExistentFileName)
        
        XCTAssertNil(result, "Should return nil for non-existent file")
    }
    
    func testGetFileURLWithEmptyFileName() {
        let result = FileUtils.getFileURL(fileNameWithExtension: FileTestConstants.Paths.emptyFileName)
        
        XCTAssertNil(result, "Should return nil for empty file name")
    }
    
    func testGetFileURLWithInvalidFileName() {
        let result = FileUtils.getFileURL(fileNameWithExtension: FileTestConstants.Paths.invalidFileName)
        
        XCTAssertNil(result, "Should return nil for invalid file name")
    }
    
    func testEncodeFileToBase64WithValidFile() {
        guard let fileURL = FileUtils.getFileURL(fileNameWithExtension: FileTestConstants.Paths.samplePDFFullName) else {
            XCTFail("Sample PDF should exist")
            return
        }
        
        let result = FileUtils.encodeFileToBase64(fileURL: fileURL)
        
        XCTAssertNotNil(result, "Should encode valid file to base64")
        XCTAssertFalse(result?.isEmpty == true, "Base64 string should not be empty")
        
        if let base64String = result {
            let decodedData = Data(base64Encoded: base64String)
            XCTAssertNotNil(decodedData, "Result should be valid base64")
        }
    }
    
    func testEncodeFileToBase64WithNonExistentFile() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let nonExistentURL = documentsURL.appendingPathComponent(FileTestConstants.Paths.nonExistentFileName)
        
        let result = FileUtils.encodeFileToBase64(fileURL: nonExistentURL)
        
        XCTAssertNil(result, "Should return nil for non-existent file")
    }
    
    func testEncodeFileToBase64WithEmptyFile() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let emptyFileURL = documentsURL.appendingPathComponent("empty-test.txt")
        
        let emptyData = Data()
        do {
            try emptyData.write(to: emptyFileURL)
            addTempFile(emptyFileURL)
            
            let result = FileUtils.encodeFileToBase64(fileURL: emptyFileURL)
            
            XCTAssertNotNil(result, "Should encode empty file to base64")
            XCTAssertEqual(result, "", "Empty file should encode to empty base64 string")
        } catch {
            XCTFail("Failed to create empty test file: \(error)")
        }
    }
    
    func testGetBase64EncodedDocumentWithValidFile() {
        let result = FileUtils.getBase64EncodedDocument(fileNameWithExtension: FileTestConstants.Paths.samplePDFFullName)
        
        XCTAssertNotNil(result, "Should encode valid document to base64")
        XCTAssertFalse(result?.isEmpty == true, "Base64 string should not be empty")
        
        if let base64String = result {
            let decodedData = Data(base64Encoded: base64String)
            XCTAssertNotNil(decodedData, "Should be valid base64")
            
            let reEncodedBase64 = decodedData?.base64EncodedString()
            XCTAssertEqual(base64String, reEncodedBase64, "Round-trip encoding should match")
        }
    }
    
    func testGetBase64EncodedDocumentWithNonExistentFile() {
        let result = FileUtils.getBase64EncodedDocument(fileNameWithExtension: FileTestConstants.Paths.nonExistentFileName)
        
        XCTAssertNil(result, "Should return nil for non-existent file")
    }
    
    func testGetBase64EncodedDocumentWithEmptyFileName() {
        let result = FileUtils.getBase64EncodedDocument(fileNameWithExtension: FileTestConstants.Paths.emptyFileName)
        
        XCTAssertNil(result, "Should return nil for empty file name")
    }
    
    func testDecodeBase64ToDataWithValidBase64() {
        let result = FileUtils.decodeBase64ToData(base64String: FileTestConstants.TestData.sampleBase64)
        
        XCTAssertNotNil(result, "Should decode valid base64")
        
        if let data = result {
            let decodedString = String(data: data, encoding: .utf8)
            XCTAssertEqual(decodedString, "Hello World!", "Should decode to correct string")
        }
    }
    
    func testDecodeBase64ToDataWithInvalidBase64() {
        let result = FileUtils.decodeBase64ToData(base64String: FileTestConstants.TestData.malformedBase64)
        
        XCTAssertNil(result, "Should return nil for invalid base64")
    }
    
    func testDecodeBase64ToDataWithEmptyBase64() {
        let result = FileUtils.decodeBase64ToData(base64String: FileTestConstants.TestData.emptyBase64)
        
        XCTAssertNotNil(result, "Should handle empty base64 string")
        XCTAssertTrue(result?.isEmpty == true, "Empty base64 should decode to empty data")
    }
    
    func testDecodeBase64ToDataWithValidPDFBase64() {
        let result = FileUtils.decodeBase64ToData(base64String: FileTestConstants.TestData.validPDFBase64)
        
        XCTAssertNotNil(result, "Should decode valid PDF base64")
        
        if let data = result {
            let pdfSignature = data.prefix(4)
            let expectedSignature = Data([0x25, 0x50, 0x44, 0x46])
            XCTAssertEqual(pdfSignature, expectedSignature, "Should decode to valid PDF data")
        }
    }
    
    func testDecodeAndSaveBase64DocumentWithValidData() {
        let result = FileUtils.decodeAndSaveBase64Document(
            base64String: FileTestConstants.TestData.sampleBase64,
            fileNameWithExtension: FileTestConstants.Paths.testOutputFile
        )
        
        XCTAssertNotNil(result, "Should save decoded base64 to file")
        
        if let fileURL = result {
            addTempFile(fileURL)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "File should exist at returned URL")
            
            do {
                let savedData = try Data(contentsOf: fileURL)
                let originalData = Data(base64Encoded: FileTestConstants.TestData.sampleBase64)
                XCTAssertEqual(savedData, originalData, "Saved data should match original decoded data")
            } catch {
                XCTFail("Failed to read saved file: \(error)")
            }
        }
    }
    
    func testDecodeAndSaveBase64DocumentWithInvalidBase64() {
        let result = FileUtils.decodeAndSaveBase64Document(
            base64String: FileTestConstants.TestData.malformedBase64,
            fileNameWithExtension: FileTestConstants.Paths.testOutputFile
        )
        
        XCTAssertNil(result, "Should return nil for invalid base64")
    }
    
    func testDecodeAndSaveBase64DocumentWithEmptyBase64() {
        let result = FileUtils.decodeAndSaveBase64Document(
            base64String: FileTestConstants.TestData.emptyBase64,
            fileNameWithExtension: "empty-output.txt"
        )
        
        XCTAssertNotNil(result, "Should save empty data from empty base64")
        
        if let fileURL = result {
            addTempFile(fileURL)
            
            do {
                let savedData = try Data(contentsOf: fileURL)
                XCTAssertTrue(savedData.isEmpty, "Empty base64 should create empty file")
            } catch {
                XCTFail("Failed to read empty file: \(error)")
            }
        }
    }
    
    func testDecodeAndSaveBase64DocumentWithPDFData() {
        let result = FileUtils.decodeAndSaveBase64Document(
            base64String: FileTestConstants.TestData.validPDFBase64,
            fileNameWithExtension: "test-pdf-output.pdf"
        )
        
        XCTAssertNotNil(result, "Should save PDF base64 to file")
        
        if let fileURL = result {
            addTempFile(fileURL)
            
            do {
                let savedData = try Data(contentsOf: fileURL)
                let pdfSignature = savedData.prefix(4)
                let expectedSignature = Data([0x25, 0x50, 0x44, 0x46])
                XCTAssertEqual(pdfSignature, expectedSignature, "Saved file should be valid PDF")
            } catch {
                XCTFail("Failed to read saved PDF: \(error)")
            }
        }
    }
    
    func testFullRoundTripEncodeAndDecode() {
        guard let originalBase64 = FileUtils.getBase64EncodedDocument(fileNameWithExtension: FileTestConstants.Paths.samplePDFFullName) else {
            XCTFail("Should encode sample PDF to base64")
            return
        }
        
        guard let savedFileURL = FileUtils.decodeAndSaveBase64Document(
            base64String: originalBase64,
            fileNameWithExtension: "roundtrip-test.pdf"
        ) else {
            XCTFail("Should save decoded base64 to new file")
            return
        }
        
        addTempFile(savedFileURL)
        
        guard let newBase64 = FileUtils.encodeFileToBase64(fileURL: savedFileURL) else {
            XCTFail("Should encode saved file back to base64")
            return
        }
        
        XCTAssertEqual(originalBase64, newBase64, "Round-trip encoding should produce identical base64")
        
        do {
            guard let originalFileURL = FileUtils.getFileURL(fileNameWithExtension: FileTestConstants.Paths.samplePDFFullName) else {
                XCTFail("Should get original file URL")
                return
            }
            
            let originalData = try Data(contentsOf: originalFileURL)
            let savedData = try Data(contentsOf: savedFileURL)
            
            XCTAssertEqual(originalData, savedData, "Round-trip should produce identical file data")
        } catch {
            XCTFail("Failed to compare file data: \(error)")
        }
    }
    
    func testErrorHandlingWithCorruptedFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let result = FileUtils.encodeFileToBase64(fileURL: documentsURL)
        
        XCTAssertNil(result, "Should return nil when trying to encode directory as file")
    }
    
    func testBinaryDataHandling() {
        let binaryBase64 = FileTestConstants.TestData.smallBinaryData.base64EncodedString()
        
        let decodedData = FileUtils.decodeBase64ToData(base64String: binaryBase64)
        XCTAssertEqual(decodedData, FileTestConstants.TestData.smallBinaryData, "Should correctly handle binary data")
        
        let saveResult = FileUtils.decodeAndSaveBase64Document(
            base64String: binaryBase64,
            fileNameWithExtension: "binary-test.bin"
        )
        
        XCTAssertNotNil(saveResult, "Should save binary data")
        
        if let fileURL = saveResult {
            addTempFile(fileURL)
            
            do {
                let savedData = try Data(contentsOf: fileURL)
                XCTAssertEqual(savedData, FileTestConstants.TestData.smallBinaryData, "Binary data should be preserved")
            } catch {
                XCTFail("Failed to read binary file: \(error)")
            }
        }
    }
} 
