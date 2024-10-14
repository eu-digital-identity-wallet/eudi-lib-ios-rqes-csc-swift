import Foundation

internal final actor InfoService: InfoServiceType {
    
    internal init() {}

    internal func getInfo(request: InfoServiceRequest? = nil) async throws -> InfoServiceResponse {
        
        let req = request ?? InfoServiceRequest(lang: "en-US")

        try InfoServiceValidator.validateLanguage(req.lang)

        return try await InfoClient.makeRequest(for: req)
    }

    
}
