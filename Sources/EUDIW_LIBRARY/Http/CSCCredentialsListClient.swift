import Foundation

internal final actor CSCCredentialsListClient {

    internal static func makeRequest(for request: CSCCredentialsListRequest, accessToken: String, oauth2BaseUrl:String) async throws -> CSCCredentialsListResponse {
        
        let endpoint = "/csc/v2/credentials/list"
        let baseUrl = oauth2BaseUrl + endpoint

        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ClientError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(CSCCredentialsListResponse.self, from: data)
        } catch {
            throw CSCCredentialsListError.decodingFailed
        }
    }
}
