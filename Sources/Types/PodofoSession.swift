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
import PoDoFo

public struct PodofoSession {
    public let id: String
    public let session: PodofoWrapper
    public var conformanceLevel: ConformanceLevel
    public var endCertificate: String
    public var chainCertificates: [String]
    public var tsrLT: String?
    public var tsrLTA: String?
    public var crlUrls: Set<String>
    public var ocspUrls: Set<String>
    
    public init(
        id: String,
        session: PodofoWrapper,
        conformanceLevel: ConformanceLevel,
        endCertificate: String,
        chainCertificates: [String] = []

    ) {
        self.id = id
        self.session = session
        self.conformanceLevel = conformanceLevel
        self.endCertificate = endCertificate
        self.chainCertificates = chainCertificates
        self.tsrLT = nil
        self.tsrLTA = nil
        self.crlUrls = Set<String>()
        self.ocspUrls = Set<String>()
    }
}
