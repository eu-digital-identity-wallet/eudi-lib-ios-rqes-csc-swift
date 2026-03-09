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

public protocol DocumentRetrieving: AuthorizationRequestResolving & Dispatching, Sendable {
    var config: DocumentRetrievalConfiguration { get }
    func parse(url: URL) async throws -> Result<UnvalidatedRequest, Error>
}

public final class DocumentRetrieval: DocumentRetrieving {
    
    private let resolver: AuthorizationRequestResolving
    private let dispatcher: Dispatching
    public let config: DocumentRetrievalConfiguration
    
    public init(
        config: DocumentRetrievalConfiguration
    ) {
        self.resolver = AuthorizationRequestResolver()
        self.dispatcher = Dispatcher()
        self.config = config
    }
    
    
    public func parse(url: URL) async throws -> Result<UnvalidatedRequest, Error> {
        UnvalidatedRequest.make(from: url.absoluteString)
    }
    
    public func resolve(documentRetrievalConfiguration: DocumentRetrievalConfiguration, unvalidatedRequest: UnvalidatedRequest) async throws -> AuthorizationRequest {
        try await resolver.resolve(documentRetrievalConfiguration: documentRetrievalConfiguration, unvalidatedRequest: unvalidatedRequest)
    }
    
    public func dispatch(poster: Posting, reslovedData: ResolvedRequestData, consent: Consent) async throws -> DispatchOutcome {
        let documentWithSignature: [String]? = try consent.documentsWithSignature()?.compactMap { document in
            guard let url = URL(string: document) else {
                throw ValidationError.emptyValue
            }
            let data = try Data(contentsOf: url)
            guard let text = String(data: data, encoding: .utf8) else {
                throw ValidationError.emptyValue
            }
            return text
        }
        
        return try await dispatcher.dispatch(
            poster: Poster(),
            reslovedData: reslovedData,
            consent: .positive(
                documentWithSignature: documentWithSignature,
                signatureObject: nil
            )
        )
    }
}

