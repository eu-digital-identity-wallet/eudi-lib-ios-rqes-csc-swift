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

final actor CSCCredentialsPushedAuthorizeClient {

    static func sendPushedAuthorizeRequest(
        for request: CSCCredentialsPushedAuthorizeRequest,
        accessToken: String,
        oauth2BaseUrl:String
    ) async throws -> CSCCredentialsPushedAuthorizeResponse {
        
        let endpoint = "/oauth2/pushed_authorize"
        let baseUrl = oauth2BaseUrl + endpoint        
        
        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestBodyData = try encoder.encode(request)
        urlRequest.httpBody = requestBodyData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw ClientError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pushedAuthorizeResponse = try decoder.decode(CSCCredentialsPushedAuthorizeResponse.self, from: data)
        
        return pushedAuthorizeResponse
    }
}
