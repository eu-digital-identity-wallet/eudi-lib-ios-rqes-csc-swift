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

struct DocumentDigest: Codable, Sendable {
    let label: String
    let hash: String
}

struct AuthorizationDetailsItem: Codable, Sendable {
    let documentDigests: [DocumentDigest]
    let credentialID: String
    let hashAlgorithmOID: String
    let locations: [String]
    let type: String
}

typealias AuthorizationDetails = [AuthorizationDetailsItem]
