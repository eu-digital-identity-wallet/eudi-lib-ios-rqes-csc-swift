import XCTest
@testable import EUDIW_LIBRARY

final class InfoServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvokeInfoService() async throws {
        let request = InfoServiceRequest(lang: "en-US")

        do {
            let eudiw = await EUDIW()
            let response = try await eudiw.getInfo(request: request)

            prettyPrintResponseAsJSON(response)
        } catch {
            if let localizedError = error as? LocalizedError {
                print("Error: \(localizedError.errorDescription ?? "Unknown error")")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(error as? InfoServiceError, InfoServiceError.invalidLanguage)
        }
    }
    func prettyPrintResponseAsJSON(_ response: InfoServiceResponse) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Pretty Printed JSON Response:")
                print(jsonString)
            }
        } catch {
            print("Failed to encode InfoServiceResponse to JSON: \(error)")
        }
    }
}
