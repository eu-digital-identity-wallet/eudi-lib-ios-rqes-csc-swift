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

final class JSONUtilsTests: XCTestCase {

    private struct TestCodable: Codable, Equatable {
        let name: String
        let age: Int
        let url: String
    }

    private struct TestInvalidCodable: Codable {
        let value: Double
    }
    
    private struct EmptyCodable: Codable, Equatable {}
    
    private struct NestedCodable: Codable, Equatable {
        let id: Int
        let nested: TestCodable
    }

    private struct OptionalCodable: Codable, Equatable {
        let id: Int
        let name: String?
    }

    func testStringify_withValidObject_returnsCorrectJSONString() throws {
        let object = TestCodable(name: "John Doe", age: 30, url: "https://example.com/a/b")
        let jsonString = JSONUtils.stringify(object)

        XCTAssertNotNil(jsonString)
        
        let data = try XCTUnwrap(jsonString?.data(using: .utf8))
        let decodedObject = try JSONDecoder().decode(TestCodable.self, from: data)

        XCTAssertEqual(object, decodedObject)
    }

    func testStringify_withURL_doesNotEscapeSlashes() {
        let object = TestCodable(name: "Jane Doe", age: 25, url: "https://example.com/path")
        let jsonString = JSONUtils.stringify(object)

        XCTAssertNotNil(jsonString)
        XCTAssertFalse(jsonString!.contains("\\/"))
    }

    func testStringify_withInvalidObject_returnsNil() {
        let invalidObject = TestInvalidCodable(value: .infinity)
        let jsonString = JSONUtils.stringify(invalidObject)
        XCTAssertNil(jsonString)
    }

    func testStringify_withEmptyObject_returnsEmptyJSON() {
        let object = EmptyCodable()
        let jsonString = JSONUtils.stringify(object)
        XCTAssertEqual(jsonString, "{}")
    }
    
    func testStringify_withArrayOfObjects_returnsJSONArrayString() throws {
        let objects = [
            TestCodable(name: "John Doe", age: 30, url: "https://example.com/a"),
            TestCodable(name: "Jane Doe", age: 25, url: "https://example.com/b")
        ]
        let jsonString = JSONUtils.stringify(objects)
        XCTAssertNotNil(jsonString)

        let data = try XCTUnwrap(jsonString?.data(using: .utf8))
        let decodedObjects = try JSONDecoder().decode([TestCodable].self, from: data)
        XCTAssertEqual(objects, decodedObjects)
    }
    
    func testStringify_withNestedObject_returnsNestedJSONString() throws {
        let nested = TestCodable(name: "Nested", age: 1, url: "https://example.com/nested")
        let object = NestedCodable(id: 123, nested: nested)
        let jsonString = JSONUtils.stringify(object)
        XCTAssertNotNil(jsonString)
        
        let data = try XCTUnwrap(jsonString?.data(using: .utf8))
        let decodedObject = try JSONDecoder().decode(NestedCodable.self, from: data)
        XCTAssertEqual(object, decodedObject)
        XCTAssertTrue(jsonString!.contains(#""id":123"#))
        XCTAssertTrue(jsonString!.contains(#""nested""#))
    }

    func testPrettyPrintResponseAsJSON_withValidObjectNoCrash() {
        let object = TestCodable(name: "John Doe", age: 30, url: "https://example.com/a/b")
        JSONUtils.prettyPrintResponseAsJSON(object)
    }

    func testPrettyPrintResponseAsJSON_withInvalidObjectNoCrash() {
        let invalidObject = TestInvalidCodable(value: .infinity)
        JSONUtils.prettyPrintResponseAsJSON(invalidObject)
    }
} 
