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

public final actor HTTPService: HTTPClientType, Sendable {
    public init() {}
    
    public func getData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        return (data, httpResponse)
    }
    
    public func postData(_ data: Data, to url: URL, contentType: String, accept: String?) async throws -> (Data, HTTPURLResponse) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        if let accept = accept {
            urlRequest.setValue(accept, forHTTPHeaderField: "Accept")
        }
        
        let (responseData, response) = try await URLSession.shared.upload(for: urlRequest, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        return (responseData, httpResponse)
    }
    
    public func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        return try await URLSession.shared.upload(for: request, from: data)
    }
} 