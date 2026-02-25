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

// MARK: - HTTP basics

public enum HttpMethod: String, Sendable {
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
}

public struct HTTPHeader: Sendable, Hashable {
    public let field: String
    public let value: String
    public init(_ field: String, _ value: String) { self.field = field; self.value = value }
}

public enum RequestBody: Sendable {
    case none
    case data(Data, contentType: String?)
    case jsonEncodable(Data)
    case formURLEncoded([String: String], encoding: String.Encoding = .utf8)
}

public protocol RequestProtocol: Sendable {
    associatedtype Response: Decodable & Sendable
    
    /// Either provide a full URL, or have your client compose baseURL + path.
    var url: URL { get }
    
    var method: HttpMethod { get }
    var headers: [HTTPHeader] { get }
    var body: RequestBody { get }
    
    /// Optional: request-specific timeout
    var timeout: TimeInterval? { get }
}

public extension RequestProtocol {
    var headers: [HTTPHeader] { [] }
    var body: RequestBody { .none }
    var timeout: TimeInterval? { nil }
}

// MARK: - Building URLRequest

public enum RequestBuildError: Error {
    case jsonEncodingFailed
}

public struct URLRequestBuilder: Sendable {
    
    public init() {}
    
    public func build<R: RequestProtocol>(_ request: R) throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        
        if let timeout = request.timeout {
            urlRequest.timeoutInterval = timeout
        }
        
        // Headers first (body may add/override content-type)
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.field) }
        
        // Body
        switch request.body {
        case .none:
            break
            
        case .data(let data, let contentType):
            urlRequest.httpBody = data
            if let contentType { urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type") }
            
        case .jsonEncodable(let data):
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        case .formURLEncoded(let params, let encoding):
            let data = FormEncoder.encode(params, encoding: encoding)
            urlRequest.httpBody = data
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }
    
    private func encodeAnyEncodable(_ value: any Encodable, encoder: JSONEncoder) throws -> Data {
        // Type-erasure wrapper to encode `any Encodable`
        struct AnyEncodable: Encodable {
            let value: any Encodable
            func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
        }
        return try encoder.encode(AnyEncodable(value: value))
    }
}

// MARK: - Form encoder

public enum FormEncoder {
    public static func encode(_ params: [String: String], encoding: String.Encoding = .utf8) -> Data {
        let encoded = params
            .map { "\(escape($0.key))=\(escape($0.value))" }
            .joined(separator: "&")
        
        return encoded.data(using: encoding) ?? Data()
    }
    
    private static func escape(_ string: String) -> String {
        // "application/x-www-form-urlencoded":
        // - percent-encode non-unreserved
        // - spaces become '+'
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        let percent = string.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        return percent.replacingOccurrences(of: " ", with: "+")
    }
}

// MARK: - Transport / Client

public enum HTTPError: Error {
    case invalidResponse
    case unacceptableStatus(Int, Data)
    case decodingFailed(Error)
}

public protocol Transport: Sendable {
    func send(_ urlRequest: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct URLSessionTransport: Transport {
    public let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }
    
    public func send(_ urlRequest: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw HTTPError.invalidResponse }
        return (data, http)
    }
}

public struct HTTPClient: Sendable {
    private let transport: Transport
    private let builder: URLRequestBuilder
    private let decoder: JSONDecoder
    
    public init(
        transport: Transport = URLSessionTransport(),
        builder: URLRequestBuilder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.transport = transport
        self.builder = builder
        self.decoder = decoder
    }
    
    public func send<R: RequestProtocol>(_ request: R, accept status: ClosedRange<Int> = 200...299) async throws -> R.Response {
        let urlRequest = try builder.build(request)
        let (data, http) = try await transport.send(urlRequest)
        
        guard status.contains(http.statusCode) else {
            throw HTTPError.unacceptableStatus(http.statusCode, data)
        }
        
        do {
            return try decoder.decode(R.Response.self, from: data)
        } catch {
            throw HTTPError.decodingFailed(error)
        }
    }
    
    public func sendNoDecode<R: RequestProtocol>(_ request: R, accept status: ClosedRange<Int> = 200...299) async throws -> (Data, HTTPURLResponse) where R.Response == EmptyResponse {
        let urlRequest = try builder.build(request)
        let (data, http) = try await transport.send(urlRequest)
        guard status.contains(http.statusCode) else { throw HTTPError.unacceptableStatus(http.statusCode, data) }
        return (data, http)
    }
}

public struct EmptyResponse: Decodable, Sendable {
    public init() {}
}



