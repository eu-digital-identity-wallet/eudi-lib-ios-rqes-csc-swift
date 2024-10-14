import Foundation

internal final actor InfoClient{
    internal static func makeRequest(for request: InfoServiceRequest) async throws -> InfoServiceResponse {
        let baseUrl = "https://walletcentric.signer.eudiw.dev/csc/v2/info"
        
        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }

        let urlRequest = try createUrlRequest(with: url, request: request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
 
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ClientError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(InfoServiceResponse.self, from: data)
        } catch {
            throw InfoServiceError.decodingFailed
        }
    }
    

    private static func createUrlRequest(with url: URL, request: InfoServiceRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData
        
        return urlRequest
    }
}
