import Foundation

internal struct InfoServiceValidator {

    private static let supportedLanguages = ["en-US", "gr-GR", "it-IT"]

    internal static func validateLanguage(_ lang: String?) throws {
        if let lang = lang {
            guard supportedLanguages.contains(lang) else {
                throw InfoServiceError.invalidLanguage
            }
        }
    }
}

