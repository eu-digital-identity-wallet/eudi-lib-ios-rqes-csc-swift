import Foundation

internal final actor SignDocClient {

    internal static func makeRequest(for request: SignDocRequest, accessToken: String, oauth2BaseUrl:String) async throws -> SignDocResponse {
        
        let endpoint = "/csc/v2/signatures/signDoc"
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
            throw SignDocError.invalidResponse
        }

        let signDocResponse = try JSONDecoder().decode(SignDocResponse.self, from: data)
        
        return signDocResponse
    }
}
