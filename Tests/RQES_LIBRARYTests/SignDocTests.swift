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

final class SignDocServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeSignDocServiceWithAccessToken() async throws {
        let request = SignDocRequest(
            credentialID: "GX0112348",
            SAD: "_TiHRG-bAH3XlFQZ3ndFhkXf9P24/CKN69L8gdSYp5_pw",
            documentDigests: [
                DocumentDigest(
                    hashes: ["sTOgwOm+474gFj0q0x1iSNspKqbcse4IeiqlDg/HWuI=", "HZQzZmMAIWekfGH0/ZKW1nsdt0xg3H6bZYztgsMTLw0="],
                    hashAlgorithmOID: "2.16.840.1.101.3.4.2.1",
                    signatureFormat: "P",
                    conformanceLevel: "AdES-B-T",
                    signAlgo: "1.2.840.113549.1.1.1"
                )
            ],
            documents: [
                Document(
                    document: "Q2VydGlmaWNhdGVTZXJpYWxOdW1iZ…KzBTWWVJWWZZVXptU3V5MVU9DQo=",
                    signatureFormat: "P",
                    conformanceLevel: "AdES-B-T",
                    signAlgo: "1.2.840.113549.1.1.1",
                    signedEnvelopeProperty: "Attached"
                ),
                Document(
                    document: "Q2VydGlmaWNhdGVTZXJpYWxOdW1iZXI7U3… emNNbUNiL1cyQT09DQo=",
                    signatureFormat: "C",
                    conformanceLevel: "AdES-B-B",
                    signAlgo: "1.2.840.113549.1.1.1",
                    signedEnvelopeProperty: "Attached"
                )
                
            ],
            clientData: "12345678",
            returnValidationInfo: true
        )

        let accessToken = "4/CKN69L8gdSYp5_pwH3XlFQZ3ndFhkXf9P2_TiHRG-bA"

        do {
            let rqes = await RQES()
            try await rqes.getInfo()
            let response = try await rqes.signDoc(request: request, accessToken: accessToken)
            JSONUtils.prettyPrintResponseAsJSON(response)
        } catch {

            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: SignDocResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode SignDocResponse to JSON: \(error)")
        }
    }
}
