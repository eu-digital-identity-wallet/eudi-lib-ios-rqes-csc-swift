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

import XCTest
@testable import RQESLib

final class DocumentRetrievalTests: XCTestCase {
    
    func testDocumentRetrieval() async throws {
        
        let url = "https://dev.recruitment.demo.eudiw.dev?request_uri=https://dev.recruitment.demo.eudiw.dev/api/request.jwt/a35055cd-1cbf-4c50-b384-d1b39dea5404&client_id=dev.recruitment.demo.eudiw.dev"
        
        let ocnfig: DocumentRetrievalConfiguration = .init(
            issuer: URL(string: "https://www.example.com")!,
            supportedClientIdSchemes: [
                .x509SanDns(trust: { _ in
                    return true
                })
            ]
        )
        let docRetrieve = DocumentRetrieval(
            config: ocnfig
        )
        
        let unvalidatedData = try! await docRetrieve.parse(url: URL(string: url)!)
        let request = try await docRetrieve.resolve(
            documentRetrievalConfiguration: ocnfig,
            unvalidatedRequest: unvalidatedData.get()
        )
        
        print(request)
        
        do {
            try await docRetrieve.dispatch(
                poster: Poster(),
                reslovedData: request.resolved!,
                consent: .positive(documentWithSignature: [], signatureObject: [])
            )
        } catch {
            
        }
    }
}
