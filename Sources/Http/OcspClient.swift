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

public final actor OcspClient {
    private let httpClient: HTTPClientType
    
    public init(httpClient: HTTPClientType = HTTPService()) {
        self.httpClient = httpClient
    }
    
    public func makeRequest(for request: OcspRequest) async -> Result<Data, Error> {
        
        guard let url = URL(string: request.ocspUrl) else {
            return .failure(URLError(.badURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/ocsp-request", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = Data(base64Encoded: request.ocspRequest) else {
            return .failure(ClientError.encodingFailed)
        }
        
        do {
            let (data, response) = try await httpClient.postData(
                httpBody,
                to: url,
                contentType: "application/ocsp-request",
                accept: nil
            )
            
            guard (200...299).contains(response.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "OCSP request failed"
                return .failure(ClientError.clientError(message: errorMessage, statusCode: response.statusCode))
            }
            
            return .success(data)
            
        } catch {
            return .failure(error)
        }
    }
}
