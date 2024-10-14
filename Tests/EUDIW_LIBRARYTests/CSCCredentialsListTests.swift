import XCTest
@testable import EUDIW_LIBRARY

final class CSCCredentialsListServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeCSCCredentialsListServiceWithAccessToken() async throws {
        let request = CSCCredentialsListRequest(
            credentialInfo: true,
            certificates: "chain",
            certInfo: true,
            authInfo: true
        )

        let accessToken = "4/CKN69L8gdSYp5_pwH3XlFQZ3ndFhkXf9P2_TiHRG-bA"
        let oauth2BaseUrl = "https://walletcentric.signer.eudiw.dev"

        do {
            let eudiw = await EUDIW()
            let response = try await eudiw.getCredentialsList(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
            prettyPrintResponseAsJSON(response)
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: CSCCredentialsListResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode CSCCredentialsListResponse to JSON: \(error)")
        }
    }
}
