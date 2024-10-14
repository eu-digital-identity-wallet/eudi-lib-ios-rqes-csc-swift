import XCTest
@testable import EUDIW_LIBRARY

final class SignHashServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeSignHashServiceWithAccessToken() async throws {
       
        let request = SignHashRequest(
            credentialID: "GX0112348",
            SAD: "_TiHRG-bAH3XlFQZ3ndFhkXf9P24/CKN69L8gdSYp5_pw",
            hashes: [
                "sTOgwOm+474gFj0q0x1iSNspKqbcse4IeiqlDg/HWuI=",
                "c1RPZ3dPbSs0NzRnRmowcTB4MWlTTnNwS3FiY3NlNEllaXFsRGcvSFd1ST0="
            ],
            hashAlgorithmOID: "2.16.840.1.101.3.4.2.1",
            signAlgo: "1.2.840.113549.1.1.1",
            clientData: "12345678"
        )

        let accessToken = "4/CKN69L8gdSYp5_pwH3XlFQZ3ndFhkXf9P2_TiHRG-bA"
        let oauth2BaseUrl = "https://walletcentric.signer.eudiw.dev"
        
        do {
            let eudiw = await EUDIW()
            let response = try await eudiw.signHash(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
            prettyPrintResponseAsJSON(response)
        } catch {
           
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: SignHashResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode SignHashResponse to JSON: \(error)")
        }
    }
}
