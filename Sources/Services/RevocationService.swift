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

final actor RevocationService: RevocationServiceType {
    private let crlClient: CrlClient
    private let ocspClient: OcspClient
    private let certificateClient: CertificateClient
    
    init(
        crlClient: CrlClient = CrlClient(),
        ocspClient: OcspClient = OcspClient(),
        certificateClient: CertificateClient = CertificateClient()
    ) {
        self.crlClient = crlClient
        self.ocspClient = ocspClient
        self.certificateClient = certificateClient
    }

    func getCrlData(request: CrlRequest) async throws -> CrlResponse {
        let result = try await crlClient.makeRequest(for: request).get()

        let base64String = result.base64EncodedString()
        
        return CrlResponse(crlInfoBase64: base64String)
    }
    
    func getOcspData(request: OcspRequest) async throws -> OcspResponse {
        let result = try await ocspClient.makeRequest(for: request).get()
        
        let base64String = result.base64EncodedString()
        
        return OcspResponse(ocspInfoBase64: base64String)
    }
    
    func getCertificateData(request: CertificateRequest) async throws -> CertificateResponse {
        let result = try await certificateClient.makeRequest(for: request).get()
        
        let base64String = result.base64EncodedString()
        
        return CertificateResponse(certificateBase64: base64String)
    }
}

