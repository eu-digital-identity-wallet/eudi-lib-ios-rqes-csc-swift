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

final actor InfoClient {
    private let httpClient: HTTPClientType
    
    init(httpClient: HTTPClientType = HTTPService()) {
        self.httpClient = httpClient
    }
    
    func makeRequest(for request: InfoServiceRequest, rsspUrl: String) async throws -> Result<InfoServiceResponse, ClientError> {
        let url = try rsspUrl.appendingEndpoint("/info").get()

        do {
            let jsonData = try JSONEncoder().encode(request)
            
            let (data, httpResponse) = try await httpClient.postData(
                jsonData,
                to: url,
                contentType: "application/json",
                accept: nil
            )
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Info request failed"
                return .failure(.clientError(message: errorMessage, statusCode: httpResponse.statusCode))
            }
            
            let decodedResponse = try JSONDecoder().decode(InfoServiceResponse.self, from: data)
            return .success(decodedResponse)
            
        } catch is EncodingError {
            return .failure(.encodingFailed)
        } catch is DecodingError {
            return .failure(.invalidResponse)
        } catch {
            return .failure(.noData)
        }
    }
}
