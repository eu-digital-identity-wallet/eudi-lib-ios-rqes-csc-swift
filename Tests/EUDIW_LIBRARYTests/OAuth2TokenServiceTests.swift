import XCTest
@testable import EUDIW_LIBRARY

final class OAuth2TokenServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeOAuth2TokenService() async throws {
        let request = OAuth2TokenRequest(
            grantType: "authorization_code",
            clientId: "myclientid",
            clientSecret: "myclientsecret",
            code: "FhxXf9P269L8g",
            redirectUri: "https://myclient.com/callback"
           
        )
        let oauth2BaseUrl = "https://walletcentric.signer.eudiw.dev"

        do {
            let eudiw = await EUDIW()  
            let response = try await eudiw.getOAuth2Token(request: request, oauth2BaseUrl: oauth2BaseUrl)
            
            prettyPrintResponseAsJSON(response)
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    func prettyPrintResponseAsJSON(_ response: OAuth2TokenResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode OAuth2TokenResponse to JSON: \(error)")
        }
    }
}
