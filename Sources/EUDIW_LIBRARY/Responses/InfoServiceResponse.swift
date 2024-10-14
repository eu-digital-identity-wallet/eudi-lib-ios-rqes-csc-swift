import Foundation

public struct InfoServiceResponse: Codable, Sendable {
    public let specs: String
    public let name: String
    public let logo: String
    public let region: String
    public let lang: String
    public let description: String
    public let authType: [String]
    public let oauth2: String
    public let methods: [String]
    public let validationInfo: Bool?
    public let signAlgorithms: SignAlgorithms
    public let signature_formats: SignatureFormats
    public let conformance_levels: [String]
}

public struct SignAlgorithms: Codable, Sendable {
    public let algos: [String]
    public let algoParams: [String]
}

public struct SignatureFormats: Codable, Sendable{
    public let formats: [String]
    public let envelope_properties: [[String]]
}
