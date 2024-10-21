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

final class CSCCredentialsAuthorizeServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeCSCCredentialsAuthorizeServiceWithAccessToken() async throws {
        let request = CSCCredentialsAuthorizeRequest(
            credentialID: "GX0112348",
            numSignatures: 2,
            hashes: [
                "sTOgwOm+474gFj0q0x1iSNspKqbcse4IeiqlDg/HWuI=",
                "c1RPZ3dPbSs0NzRnRmowcTB4MWlTTnNwS3FiY3NlNEllaXFsRGcvSFd1ST0="
            ],
            hashAlgorithmOID: "2.16.840.1.101.3.4.2.1",
            authData: [
                AuthData(id: "PIN", value: "123456"),
                AuthData(id: "OTP", value: "738496")
            ],
            description: "Authorization for signing PDF",
            clientData: "12345678"
        )

        let accessToken = "4/CKN69L8gdSYp5_pwH3XlFQZ3ndFhkXf9P2_TiHRG-bA"

        do {
            let rqes = await RQES()
            try await rqes.getInfo()
            let response = try await rqes.authorizeCredentials(request: request, accessToken: accessToken)
            JSONUtils.prettyPrintResponseAsJSON(response)
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                print("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: CSCCredentialsAuthorizeResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode CSCCredentialsAuthorizeResponse to JSON: \(error)")
        }
    }
}
