/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

final actor OAuth2AuthorizeClient {
    
    static func makeRequest(for request: OAuth2AuthorizeRequest, oauth2BaseUrl:String) async throws -> OAuth2AuthorizeResponse {
        
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
