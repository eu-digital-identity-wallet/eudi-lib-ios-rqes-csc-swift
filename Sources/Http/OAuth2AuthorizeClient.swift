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

final actor OAuth2AuthorizeClient: NSObject, URLSessionDelegate {
    
    static func makeRequest(for request: OAuth2AuthorizeRequest, oauth2BaseUrl: String) async throws -> OAuth2AuthorizeResponse {
        
        let endpoint = "/oauth2/authorize"
        let baseUrl = oauth2BaseUrl + endpoint
        
        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }
        
        let urlRequest = try createUrlRequest(with: url, request: request)
        let session = URLSession(configuration: .default, delegate: OAuth2AuthorizeClient(), delegateQueue: nil)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClientError.invalidResponse
            }
            
            guard let finalURL = httpResponse.url else {
                throw ClientError.invalidResponse
            }
            
            let components = URLComponents(url: finalURL, resolvingAgainstBaseURL: false)
            if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value,
               let state = components?.queryItems?.first(where: { $0.name == "state" })?.value {
                return OAuth2AuthorizeResponse(url: finalURL.absoluteString, code: code, state: state)
            } else {
                throw OAuth2AuthorizeError.invalidResponse
            }
            
        } catch {
            throw error
        }
    }

    private static func createUrlRequest(with url: URL, request: OAuth2AuthorizeRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        if !request.cookie.isEmpty {
            urlRequest.setValue(request.cookie, forHTTPHeaderField: "Cookie")
        } else {
            print("No cookie to set in headers.")
        }
        
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {

        completionHandler(nil)
    }
}
