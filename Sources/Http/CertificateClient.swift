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

public final actor CertificateClient {
    private let httpClient: HTTPClientType
    
    public init(httpClient: HTTPClientType = HTTPService()) {
        self.httpClient = httpClient
    }
    
    public func makeRequest(for request: CertificateRequest) async -> Result<Data, Error> {
        
        guard let url = URL(string: request.certificateUrl) else {
            return .failure(URLError(.badURL))
        }
        
        do {
            let (data, response) = try await httpClient.getData(from: url)
            
            guard (200...299).contains(response.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Certificate request failed"
                return .failure(ClientError.clientError(message: errorMessage, statusCode: response.statusCode))
            }
            
            return .success(data)
            
        } catch {
            return .failure(error)
        }
    }
}
