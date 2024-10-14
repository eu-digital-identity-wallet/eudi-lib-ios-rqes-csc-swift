import Foundation

internal struct CSCCredentialsListValidator {
    internal static func validate(clientID: String) throws {
        guard !clientID.isEmpty else {
            throw CSCCredentialsListError.invalidClientID
        }
    }
}
