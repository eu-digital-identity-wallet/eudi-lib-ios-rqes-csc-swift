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

final actor LoginClient {

    static func makeRequest(request: LoginRequest, oauth2BaseUrl: String) async throws -> LoginResponse {

        let endpoint = "/login"
        let baseUrl = oauth2BaseUrl + endpoint

        guard let url = URL(string: baseUrl) else {
            throw ClientError.invalidRequestURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        let (formData, boundary) = try request.toFormData()
        urlRequest.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = formData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LoginError.invalidResponse
        }

        let cookie = httpResponse.value(forHTTPHeaderField: "Set-Cookie")

        do {
            var loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            loginResponse = LoginResponse(
                message: loginResponse.message,
                cookie: cookie
            )
            return loginResponse
        } catch {
            throw LoginError.decodingFailed
        }
    }
}
