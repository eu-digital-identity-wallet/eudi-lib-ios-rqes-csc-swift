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

final actor ObtainSignedDocClient {

    static func makeRequest(for request: ObtainSignedDocRequest, accessToken: String, oauth2BaseUrl: String) async throws -> ObtainSignedDocResponse {
        let endpoint = "/signatures/obtain_signed_doc"
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
            return try JSONDecoder().decode(ObtainSignedDocResponse.self, from: data)
        } catch {
            throw ObtainSignedDocError.decodingFailed
        }
    }
}
