import Foundation

public struct SignHashResponse: Codable, Sendable {

    public let signatures: [String]?
    public let responseID: String?

    enum CodingKeys: String, CodingKey {
        case signatures
        case responseID = "response_id"
    }

    public init(
        signatures: [String]? = nil,
        responseID: String? = nil
    ) {
        self.signatures = signatures
        self.responseID = responseID
    }
}
