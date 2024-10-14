import Foundation

internal final actor SignHashClient{
    
    internal static func makeRequest(for request: SignHashRequest, accessToken: String, oauth2BaseUrl:String) async throws -> SignHashResponse {
        
        let endpoint = "/csc/v2/signatures/signHash"
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ClientError.invalidResponse
        }

        let signHashResponse = try JSONDecoder().decode(SignHashResponse.self, from: data)
        
        return signHashResponse
    }
}
