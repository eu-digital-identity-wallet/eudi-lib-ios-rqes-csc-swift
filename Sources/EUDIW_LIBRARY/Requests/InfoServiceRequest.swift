import Foundation

public struct InfoServiceRequest: Codable, Sendable {
    public let lang: String?
    
    enum CodingKeys: String, CodingKey {
        case lang
    }

    public init(
        lang: String? = nil
    ) {
        self.lang = lang
    }
}
