import Foundation

internal final actor OAuth2TokenClient {

    internal static func makeRequest(for request: OAuth2TokenRequest, oauth2BaseUrl:String) async throws -> OAuth2TokenResponse {

        let endpoint = "/oauth2/token"
        let baseUrl = oauth2BaseUrl + endpoint
        
        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.toFormBody()
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ClientError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
        } catch {
            throw OAuth2TokenError.decodingFailed
        }
    }
}
