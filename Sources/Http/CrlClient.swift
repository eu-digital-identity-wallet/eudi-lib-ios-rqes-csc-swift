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

final actor CrlClient {
    private let httpClient: HTTPClientType
    
    init(httpClient: HTTPClientType = HTTPService()) {
        self.httpClient = httpClient
    }
    
    func makeRequest(for request: CrlRequest) async throws -> Result<Data, ClientError> {
        guard let url = URL(string: request.crlUrl) else {
            return .failure(.invalidRequestURL)
        }
        
        do {
            let (data, httpResponse) = try await httpClient.getData(from: url)
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "CRL request failed"
                return .failure(.clientError(message: errorMessage, statusCode: httpResponse.statusCode))
            }
            
            return .success(data)
        } catch {
            return .failure(.noData)
        }
    }
}
