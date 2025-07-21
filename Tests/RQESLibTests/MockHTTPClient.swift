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
@testable import RQESLib

final class MockHTTPClient: HTTPClientType, @unchecked Sendable {
    
    private var mockResponses: [String: MockResponse] = [:]
    private var mockError: Error?
    
    struct MockResponse {
        let data: Data
        let statusCode: Int
        
        init(data: Data, statusCode: Int = 200) {
            self.data = data
            self.statusCode = statusCode
        }
    }
    
    func getData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        return try await performRequest(for: url)
    }
    
    func postData(_ data: Data, to url: URL, contentType: String, accept: String?) async throws -> (Data, HTTPURLResponse) {
        return try await performRequest(for: url)
    }
    
    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        let (responseData, httpResponse) = try await performRequest(for: request.url!)
        return (responseData, httpResponse as URLResponse)
    }
    
    private func performRequest(for url: URL) async throws -> (Data, HTTPURLResponse) {
        if let error = mockError {
            throw error
        }
        
        let urlString = url.absoluteString
        
        guard let mockResponse = mockResponses[urlString] else {
            throw URLError(.cannotFindHost)
        }
        
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: mockResponse.statusCode,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (mockResponse.data, httpResponse)
    }
    
    func setMockResponse(for url: String, data: Data, statusCode: Int = 200) {
        mockResponses[url] = MockResponse(data: data, statusCode: statusCode)
    }
    
    func setMockError(_ error: Error) {
        mockError = error
    }
    
    func reset() {
        mockResponses.removeAll()
        mockError = nil
    }
}

final class CapturingMockHTTPClient: HTTPClientType, @unchecked Sendable {
    
    private var mockResponses: [String: MockResponse] = [:]
    private var mockError: Error?
    var lastCapturedRequest: URLRequest?
    
    struct MockResponse {
        let data: Data
        let statusCode: Int
        
        init(data: Data, statusCode: Int = 200) {
            self.data = data
            self.statusCode = statusCode
        }
    }
    
    func getData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        return try await performRequest(for: url)
    }
    
    func postData(_ data: Data, to url: URL, contentType: String, accept: String?) async throws -> (Data, HTTPURLResponse) {
        return try await performRequest(for: url)
    }
    
    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        lastCapturedRequest = request
        
        let (responseData, httpResponse) = try await performRequest(for: request.url!)
        return (responseData, httpResponse as URLResponse)
    }
    
    private func performRequest(for url: URL) async throws -> (Data, HTTPURLResponse) {
        if let error = mockError {
            throw error
        }
        
        let urlString = url.absoluteString
        
        guard let mockResponse = mockResponses[urlString] else {
            throw URLError(.cannotFindHost)
        }
        
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: mockResponse.statusCode,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (mockResponse.data, httpResponse)
    }
    
    func setMockResponse(for url: String, data: Data, statusCode: Int = 200) {
        mockResponses[url] = MockResponse(data: data, statusCode: statusCode)
    }
    
    func setMockError(_ error: Error) {
        mockError = error
    }
    
    func reset() {
        mockResponses.removeAll()
        mockError = nil
        lastCapturedRequest = nil
    }
} 
