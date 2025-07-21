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

final class InfoServiceTests: XCTestCase {
    
    var infoService: InfoService!
    var mockHTTPClient: MockHTTPClient!
    var infoClient: InfoClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        infoClient = InfoClient(httpClient: mockHTTPClient)
        infoService = InfoService(infoClient: infoClient)
    }
    
    override func tearDown() {
        mockHTTPClient = nil
        infoClient = nil
        infoService = nil
        super.tearDown()
    }
    
    func testGetInfoWithValidRequest() async throws {
        let rsspUrl = "https://mock-rssp.example.com"
        let request = InfoServiceRequest(lang: "en-US")
        
        let mockResponseData = createRealisticInfoResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "\(rsspUrl)/info", data: mockResponseData)
        
        let response = try await infoService.getInfo(request: request, rsspUrl: rsspUrl)
        
        XCTAssertEqual(response.region, "EU", "Should return mock EU region")
        XCTAssertEqual(response.specs, "2.0.0.0", "Should return mock specs version")
        XCTAssertEqual(response.lang, "en-US", "Should return mock language")
        XCTAssertEqual(response.name, "remote Qualifies Electronic Signature R3 QTSP", "Should return mock service name")
        XCTAssertEqual(response.oauth2, "https://walletcentric.signer.eudiw.dev", "Should return mock OAuth2 URL")
        XCTAssertEqual(response.validationInfo, false, "Should return mock validation info")
        
        XCTAssertTrue(response.authType.contains("oauth2code"), "Should contain mock auth type")
        XCTAssertTrue(response.methods.contains("oauth2/authorize"), "Should contain mock method")
        XCTAssertTrue(response.methods.contains("credentials/list"), "Should contain mock method")
        XCTAssertTrue(response.conformance_levels.contains("Ades-B-B"), "Should contain mock conformance level")
        
        XCTAssertTrue(response.signAlgorithms.algos.contains("1.2.840.10045.2.1"), "Should contain mock algorithm")
        XCTAssertTrue(response.signAlgorithms.algos.contains("1.2.840.10045.4.3.2"), "Should contain mock algorithm")
        XCTAssertTrue(response.signature_formats.formats.contains("P"), "Should contain mock format")
        XCTAssertTrue(response.signature_formats.formats.contains("X"), "Should contain mock format")
    }
    
    func testGetInfoWithNilRequest() async throws {
        let rsspUrl = "https://mock-rssp.example.com"
        
        let mockResponseData = createRealisticInfoResponseJSON().data(using: .utf8)!
        mockHTTPClient.setMockResponse(for: "\(rsspUrl)/info", data: mockResponseData)
        
        let response = try await infoService.getInfo(request: nil, rsspUrl: rsspUrl)
        
        XCTAssertNotNil(response, "Should handle nil request by using default")
        XCTAssertEqual(response.lang, "en-US", "Should use default language and get mock response")
    }
    
    func testInfoServiceRequestValidation() {
        let validRequest = InfoServiceRequest(lang: "en-US")
        XCTAssertEqual(validRequest.lang, "en-US", "Should store language correctly")
        
        let nilLangRequest = InfoServiceRequest(lang: nil)
        XCTAssertNil(nilLangRequest.lang, "Should handle nil language")
        
        let emptyLangRequest = InfoServiceRequest(lang: "")
        XCTAssertEqual(emptyLangRequest.lang, "", "Should handle empty language")
        
        let languages = ["en-US", "es-ES", "fr-FR", "de-DE", "pt-PT", "it-IT"]
        for language in languages {
            let request = InfoServiceRequest(lang: language)
            XCTAssertEqual(request.lang, language, "Should handle language: \(language)")
        }
    }
    
    func testInfoServiceLanguageValidation() async {
        let rsspUrl = "https://mock-rssp.example.com"
        let request = InfoServiceRequest(lang: nil)
        
        do {
            _ = try await infoService.getInfo(request: request, rsspUrl: rsspUrl)
            XCTFail("Should throw error for invalid language")
        } catch {
            XCTAssertTrue(error is InfoServiceError, "Should throw InfoServiceError")
            if let infoError = error as? InfoServiceError {
                XCTAssertEqual(infoError, InfoServiceError.invalidLanguage, "Should be invalidLanguage error")
            }
        }
    }
    
    func testGetInfoWithServerError() async {
        let rsspUrl = "https://mock-rssp.example.com"
        let request = InfoServiceRequest(lang: "en-US")
        
        mockHTTPClient.setMockResponse(for: "\(rsspUrl)/info", 
                                      data: Data("Server Error".utf8), 
                                      statusCode: 500)
        
        do {
            _ = try await infoService.getInfo(request: request, rsspUrl: rsspUrl)
            XCTFail("Should throw error for server error")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError for server error")
            if case .clientError(let message, let statusCode) = error as? ClientError {
                XCTAssertEqual(statusCode, 500, "Should return exact mock 500 status")
                XCTAssertEqual(message, "Server Error", "Should return exact mock error message")
            }
        }
    }
    
    func testGetInfoWithMalformedJSON() async {
        let rsspUrl = "https://mock-rssp.example.com"
        let request = InfoServiceRequest(lang: "en-US")
        
        let malformedJSON = "{ invalid json response }"
        mockHTTPClient.setMockResponse(for: "\(rsspUrl)/info", data: malformedJSON.data(using: .utf8)!)
        
        do {
            _ = try await infoService.getInfo(request: request, rsspUrl: rsspUrl)
            XCTFail("Should throw error for malformed JSON")
        } catch {
            XCTAssertTrue(error is ClientError, "Should throw ClientError for malformed JSON")
        }
    }
    
    func testInfoServiceResponseJSONParsing() throws {
        let realisticJSON = createRealisticInfoResponseJSON()
        let jsonData = realisticJSON.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(InfoServiceResponse.self, from: jsonData)
        
        XCTAssertEqual(response.region, "EU")
        XCTAssertEqual(response.specs, "2.0.0.0")
        XCTAssertEqual(response.lang, "en-US")
        XCTAssertEqual(response.name, "remote Qualifies Electronic Signature R3 QTSP")
        XCTAssertEqual(response.logo, "img")
        XCTAssertEqual(response.description, "This is a test Qualified Trust Service Provider")
        XCTAssertEqual(response.oauth2, "https://walletcentric.signer.eudiw.dev")
        XCTAssertEqual(response.validationInfo, false)
        
        XCTAssertEqual(response.authType.count, 1)
        XCTAssertEqual(response.authType[0], "oauth2code")
        
        let expectedMethods = [
            "oauth2/authorize",
            "oauth2/token", 
            "credentials/list",
            "credentials/info",
            "signatures/signHash"
        ]
        XCTAssertEqual(response.methods.count, expectedMethods.count)
        for method in expectedMethods {
            XCTAssertTrue(response.methods.contains(method), "Should contain method: \(method)")
        }
        
        let expectedLevels = ["Ades-B-B", "Ades-B-T", "Ades-B-LT", "Ades-B-LTA"]
        XCTAssertEqual(response.conformance_levels.count, expectedLevels.count)
        for level in expectedLevels {
            XCTAssertTrue(response.conformance_levels.contains(level), "Should contain level: \(level)")
        }
        
        XCTAssertEqual(response.signAlgorithms.algos.count, 2)
        XCTAssertTrue(response.signAlgorithms.algos.contains("1.2.840.10045.2.1"))
        XCTAssertTrue(response.signAlgorithms.algos.contains("1.2.840.10045.4.3.2"))
        XCTAssertTrue(response.signAlgorithms.algoParams.isEmpty)
        
        let expectedFormats = ["P", "X", "C", "J"]
        XCTAssertEqual(response.signature_formats.formats.count, expectedFormats.count)
        for format in expectedFormats {
            XCTAssertTrue(response.signature_formats.formats.contains(format), "Should contain format: \(format)")
        }
        
        XCTAssertEqual(response.signature_formats.envelope_properties.count, 4)
        XCTAssertEqual(response.signature_formats.envelope_properties[0], ["Enveloped"])
        XCTAssertEqual(response.signature_formats.envelope_properties[1], ["Enveloped", "Enveloping", "Detached", "Internally detached"])
        XCTAssertEqual(response.signature_formats.envelope_properties[2], ["Enveloping", "Detached"])
        XCTAssertEqual(response.signature_formats.envelope_properties[3], ["Enveloping", "Detached"])
    }
    
    func testInfoServiceResponseWithDifferentLanguages() throws {
        let languages = ["en-US", "es-ES", "fr-FR", "de-DE"]
        
        for language in languages {
            let jsonData = createRealisticInfoResponseJSON(language: language).data(using: .utf8)!
            let decoder = JSONDecoder()
            let response = try decoder.decode(InfoServiceResponse.self, from: jsonData)
            
            XCTAssertEqual(response.lang, language, "Should parse language correctly: \(language)")
            XCTAssertEqual(response.region, "EU")
            XCTAssertEqual(response.specs, "2.0.0.0")
        }
    }
    
    func testSignAlgorithmsStructure() throws {
        let realisticJSON = createRealisticInfoResponseJSON()
        let jsonData = realisticJSON.data(using: .utf8)!
        let response = try JSONDecoder().decode(InfoServiceResponse.self, from: jsonData)
        
        let signAlgorithms = response.signAlgorithms
        XCTAssertFalse(signAlgorithms.algos.isEmpty, "Should have algorithms")
        XCTAssertTrue(signAlgorithms.algoParams.isEmpty, "Should have empty algo params")
        
        XCTAssertTrue(signAlgorithms.algos.contains("1.2.840.10045.2.1"), "Should contain ECDSA OID")
        XCTAssertTrue(signAlgorithms.algos.contains("1.2.840.10045.4.3.2"), "Should contain ECDSA with SHA256 OID")
    }
    
    func testSignatureFormatsStructure() throws {
        let realisticJSON = createRealisticInfoResponseJSON()
        let jsonData = realisticJSON.data(using: .utf8)!
        let response = try JSONDecoder().decode(InfoServiceResponse.self, from: jsonData)
        
        let signatureFormats = response.signature_formats
        XCTAssertFalse(signatureFormats.formats.isEmpty, "Should have formats")
        XCTAssertFalse(signatureFormats.envelope_properties.isEmpty, "Should have envelope properties")
        
        XCTAssertEqual(signatureFormats.formats.count, signatureFormats.envelope_properties.count, 
                      "Should have matching number of formats and envelope properties")
    }
    
    private func createRealisticInfoResponseJSON(language: String = "en-US") -> String {
        return """
        {
          "region" : "EU",
          "specs" : "2.0.0.0",
          "lang" : "\(language)",
          "signAlgorithms" : {
            "algos" : [
              "1.2.840.10045.2.1",
              "1.2.840.10045.4.3.2"
            ],
            "algoParams" : [

            ]
          },
          "methods" : [
            "oauth2/authorize",
            "oauth2/token",
            "credentials/list",
            "credentials/info",
            "signatures/signHash"
          ],
          "conformance_levels" : [
            "Ades-B-B",
            "Ades-B-T",
            "Ades-B-LT",
            "Ades-B-LTA"
          ],
          "logo" : "img",
          "authType" : [
            "oauth2code"
          ],
          "oauth2" : "https://walletcentric.signer.eudiw.dev",
          "validationInfo" : false,
          "description" : "This is a test Qualified Trust Service Provider",
          "signature_formats" : {
            "formats" : [
              "P",
              "X",
              "C",
              "J"
            ],
            "envelope_properties" : [
              [
                "Enveloped"
              ],
              [
                "Enveloped",
                "Enveloping",
                "Detached",
                "Internally detached"
              ],
              [
                "Enveloping",
                "Detached"
              ],
              [
                "Enveloping",
                "Detached"
              ]
            ]
          },
          "name" : "remote Qualifies Electronic Signature R3 QTSP"
        }
        """
    }
}