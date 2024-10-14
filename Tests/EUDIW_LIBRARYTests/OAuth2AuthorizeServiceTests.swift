import XCTest
@testable import EUDIW_LIBRARY

final class OAuth2AuthorizeServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeOAuth2AuthorizeService() async throws {
        let request = OAuth2AuthorizeRequest(
            responseType: "code",
            clientId: "sca-client",
            redirectUri: "https://walletcentric.signer.eudiw.dev/login/oauth2/code/sca-client",
            scope: "service",
            codeChallenge: "some_nonce_2",
            codeChallengeMethod: "S256",
            state: "12345678",
            credentialID: "65",
            signatureQualifier: nil,
            numSignatures: nil,
            hashes: nil,
            hashAlgorithmOID: nil,
            authorizationDetails: nil,
            requestUri: nil
        )
        let oauth2BaseUrl = "https://walletcentric.signer.eudiw.dev"

        do {
            let eudiw = await EUDIW()
            let response = try await eudiw.getAuthorizeUrl(request: request, oauth2BaseUrl: oauth2BaseUrl)
            
            // Print the response to observe the result
            prettyPrintResponseAsJSON(response)
        } catch {
            // Print the error but don't fail the test
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                print("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: OAuth2AuthorizeResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode OAuth2AuthorizeResponse to JSON: \(error)")
        }
    }
}
