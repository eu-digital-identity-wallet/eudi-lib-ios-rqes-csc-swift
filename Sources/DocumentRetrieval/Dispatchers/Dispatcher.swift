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

struct DirectPostHTTP: RequestProtocol {
    typealias Response = EmptyResponse
    
    let url: URL
    let method: HttpMethod = .post
    let headers: [HTTPHeader] = []
    let body: RequestBody
    
    init(url: URL, parameters: [String: String]) {
        self.url = url
        self.body = .formURLEncoded(parameters, encoding: .ascii)
    }
}

public protocol Dispatching: Sendable {
    func dispatch(poster: Posting, reslovedData: ResolvedRequestData, consent: Consent) async throws -> DispatchOutcome
}


public actor Dispatcher: Dispatching {
    
    private let networking: Networking
    
    public init(networking: Networking = URLSession.shared) {
        self.networking = networking
    }
    
    public func dispatch(
        poster: Posting,
        reslovedData: ResolvedRequestData,
        consent: Consent
    ) async throws -> DispatchOutcome {
        
        let (responseURL, payload) = try makeResponse(reslovedData: reslovedData, consent: consent)
        let parameters = DirectPostForm.parameters(of: payload)
        
        let req = DirectPostHTTP(url: responseURL, parameters: parameters)
        
        switch await poster.send(req) {
        case .success((let data, let http)):
            if http.statusCode == 200 {
                return .accepted(redirectURI: Self.extractRedirectURI(from: data))
            } else {
                let body = String(data: data, encoding: .utf8) ?? ""
                return .rejected(reason: "HTTP \(http.statusCode). \(body)")
            }
            
        case .failure(let err):
            return .rejected(reason: err.localizedDescription)
        }
    }
    
    private func makeResponse(
        reslovedData: ResolvedRequestData,
        consent: Consent
    ) throws -> (URL, AuthorizationResponsePayload) {
        
        guard let responseURL = reslovedData.responseUri else {
            throw PostError.invalidUrl
        }
        
        switch consent {
        case .positive(let documentWithSignature, let signatureObject):
            let payload = AuthorizationResponsePayload.success(
                documentWithSignature: documentWithSignature,
                signatureObject: signatureObject,
                state: reslovedData.state
            )
            return (responseURL, payload)
            
        case .negative:
            let payload = AuthorizationResponsePayload.noConsensusResponseData(
                state: reslovedData.state
            )
            return (responseURL, payload)
        }
    }
    
    private static func extractRedirectURI(from data: Data) -> URL? {
        guard
            let obj = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = obj as? [String: Any],
            let redirect = dict["redirect_uri"] as? String,
            let url = URL(string: redirect)
        else {
            return nil
        }
        return url
    }
}

public enum AuthorizationResponsePayload: Sendable {
    case success(
        documentWithSignature: [String]?,
        signatureObject: [String]?,
        state: String?
    )
    case invalidRequest(
        error: String,
        state: String?
    )
    case noConsensusResponseData(
        state: String?
    )
}

public enum AuthorizationRequestErrorCode: String, Sendable {
    case userCancelled = "user_cancelled"
    
    static func fromError(_ error: String) -> AuthorizationRequestErrorCode? {
        return nil
    }
    
    var code: String { rawValue }
}

internal enum DirectPostForm {
    private static let documentWithSignature = "documentWithSignature"
    private static let signatureObject = "signatureObject"
    private static let stateFormParam = "state"
    private static let errorFormParam = "error"
    
    static func parameters(of payload: AuthorizationResponsePayload) -> [String: String] {
        switch payload {
            
        case .success(let docs, let sigs, let state):
            var dict: [String: String] = [:]
            
            if let docs {
                dict[documentWithSignature] = docs.asJSONParam()
            }
            
            if let sigs {
                dict[signatureObject] = sigs.asJSONParam()
            }
            
            if let state {
                dict[stateFormParam] = state
            }
            
            return dict
            
        case .invalidRequest(let error, let state):
            var dict: [String: String] = [:]
            
            let code = AuthorizationRequestErrorCode.fromError(error)?.code ?? error
            dict[errorFormParam] = code
            
            if let state {
                dict[stateFormParam] = state
            }
            
            return dict
            
        case .noConsensusResponseData(let state):
            var dict: [String: String] = [:]
            
            dict[errorFormParam] = AuthorizationRequestErrorCode.userCancelled.code
            
            if let state {
                dict[stateFormParam] = state
            }
            
            return dict
        }
    }
    
}

internal extension Array where Element == String {
    func asJSONParam() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []),
              let s = String(data: data, encoding: .utf8)
        else { return "[]" }
        return s
    }
}

internal enum FormData {
    
    /// Encodes parameters as `application/x-www-form-urlencoded`
    static func encode(parameters: [String: String]) -> Data {
        let encoded = parameters
            .map { key, value in
                "\(escape(key))=\(escape(value))"
            }
            .joined(separator: "&")
        
        return encoded.data(using: .ascii, allowLossyConversion: true) ?? Data()
    }
    
    /// x-www-form-urlencoded escaping:
    /// - space becomes '+'
    /// - everything else percent-encoded (RFC 3986-ish), with a conservative allowed set.
    private static func escape(_ string: String) -> String {
        // Allowed unreserved: ALPHA / DIGIT / "-" / "." / "_" / "~"
        let allowed = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "-._~"))
        
        /// First, percent-encode (UTF-8), then replace spaces with '+'
        /// (If you *must* match strict US-ASCII behaviour end-to-end, keep your inputs ASCII.)
        let percentEncoded = string.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        return percentEncoded.replacingOccurrences(of: " ", with: "+")
    }
}

