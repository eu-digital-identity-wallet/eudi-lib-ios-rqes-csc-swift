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

final actor CSCCredentialsListClient {

    static func makeRequest(for request: CSCCredentialsListRequest, accessToken: String, oauth2BaseUrl: String) async throws -> Result<CSCCredentialsListResponse, ClientError> {
        
        let endpoint = "/csc/v2/credentials/list"
        let baseUrl = oauth2BaseUrl + endpoint

        guard let url = URL(string: baseUrl) else {
            return .failure(ClientError.invalidRequestURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            return .failure(ClientError.encodingFailed)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(ClientError.invalidResponse)
        }

        if (200...299).contains(httpResponse.statusCode) {
            do {
                let decodedResponse = try JSONDecoder().decode(CSCCredentialsListResponse.self, from: data)
                return .success(decodedResponse)
            } catch {
                return .failure(ClientError.clientError(data: data, statusCode: httpResponse.statusCode))
            }
        } else {
            return .failure(ClientError.clientError(data: data, statusCode: httpResponse.statusCode))
        }
    }
}
