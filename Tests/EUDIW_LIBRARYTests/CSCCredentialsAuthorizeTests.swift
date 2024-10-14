import XCTest
@testable import EUDIW_LIBRARY

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
        let oauth2BaseUrl = "https://walletcentric.signer.eudiw.dev"

        do {
            let eudiw = await EUDIW()
            let response = try await eudiw.authorizeCredentials(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
            prettyPrintResponseAsJSON(response)
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
