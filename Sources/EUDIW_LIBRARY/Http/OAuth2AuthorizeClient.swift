import Foundation

internal final actor OAuth2AuthorizeClient {
    
    internal static func makeRequest(for request: OAuth2AuthorizeRequest, oauth2BaseUrl:String) async throws -> OAuth2AuthorizeResponse {
        
        let endpoint = "/oauth2/authorize"
        let baseUrl = oauth2BaseUrl + endpoint
        
        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }

        let urlRequest = try createUrlRequest(with: url, request: request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ClientError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(OAuth2AuthorizeResponse.self, from: data)
        } catch {
            throw OAuth2AuthorizeError.decodingFailed
        }
    }

    private static func createUrlRequest(with url: URL, request: OAuth2AuthorizeRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET" 
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let queryItems = request.toQueryItems()
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems

        if let completeUrl = components?.url {
            urlRequest.url = completeUrl
        } else {
            throw OAuth2AuthorizeError.invalidAuthorizationDetails
        }
        
        return urlRequest
    }
}
