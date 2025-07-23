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

final actor OAuth2TokenClient {
    
    static func makeRequest(for request: OAuth2TokenRequest, issuerURL: String) async throws -> Result<AccessTokenResponse, ClientError> {
        let urlResult = issuerURL.appendingEndpoint("/oauth2/token")

        guard case let .success(baseUrl) = urlResult else {
            return .failure(.invalidRequestURL)
        }

        var url = baseUrl
        
        if let authorizationDetails = request.authorizationDetails, !authorizationDetails.isEmpty {
            var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "authorization_details", value: authorizationDetails)]
            url = components?.url ?? baseUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.toFormBody()

        if let auth = request.auth {
            let loginString = "\(auth.username):\(auth.password)"
            guard let loginData = loginString.data(using: .utf8) else {
                throw ClientError.invalidRequestURL
            }
            let base64LoginString = loginData.base64EncodedString()
            urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard response is HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        return handleResponse(data, response, ofType: AccessTokenResponse.self)
        
    }
}
