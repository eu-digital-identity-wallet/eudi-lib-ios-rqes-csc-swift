import Foundation

internal final actor CSCCredentialsAuthorizeClient {

    internal static func makeRequest(for request: CSCCredentialsAuthorizeRequest, accessToken: String, oauth2BaseUrl:String) async throws -> CSCCredentialsAuthorizeResponse {
        
        let endpoint = "/credentials/authorize"  
        let baseUrl = oauth2BaseUrl + endpoint
        
        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 202 else {
            throw ClientError.invalidResponse
        }

        let credentialsAuthorizeResponse = try JSONDecoder().decode(CSCCredentialsAuthorizeResponse.self, from: data)
        
        return credentialsAuthorizeResponse
    }
}
