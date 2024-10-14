import XCTest
@testable import EUDIW_LIBRARY

final class CSCCredentialsPushedAuthorizeTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeCSCCredentialsPushedAuthorizeWithAccessToken() async throws {
        let request = CSCCredentialsPushedAuthorizeRequest(
            clientId: "example_client_id",
            responseType: "code",
            redirectUri: "https://www.example.com/callback",
            scope: "service",
            codeChallenge: "K2-ltc83acc4h0c9w6ESC_rEMTJ3bww-uCHaoeK1t8U",
            codeChallengeMethod: "S256",
            authorizationDetails: AuthorizationDetails(
                credentialID: "GX0112348",
                signatureQualifier: "eu_eidas_qes",
                documentDigests: [
                    PushedAuthorizedDocumentDigest(hash: "sTOgwOm+474gFj0q0x1iSNspKqbcse4IeiqlDg/HWuI=", label: "Example Contract"),
                    PushedAuthorizedDocumentDigest(hash: "HZQzZmMAIWekfGH0/ZKW1nsdt0xg3H6bZYztgsMTLw0=", label: "Example Terms of Service")
                ],
                hashAlgorithmOID: "2.16.840.1.101.3.4.2.1"
            ),
            state: "12345678"
        )

        let accessToken = "4/CKN69L8gdSYp5_pwH3XlFQZ3ndFhkXf9P2_TiHRG-bA"
        let oauth2BaseUrl = "https://walletcentric.signer.eudiw.dev"

        do {
            let eudiw = await EUDIW()
            let response = try await eudiw.pushedAuthorize(request: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
            prettyPrintResponseAsJSON(response)
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                print("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: CSCCredentialsPushedAuthorizeResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode CSCCredentialsPushedAuthorizeResponse to JSON: \(error)")
        }
    }
}
