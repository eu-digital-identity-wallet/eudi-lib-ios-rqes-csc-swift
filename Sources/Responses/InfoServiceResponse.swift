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

public struct InfoServiceResponse: Codable, Sendable {
    public let specs: String
    public let name: String
    public let logo: String
    public let region: String
    public let lang: String
    public let description: String
    public let authType: [String]
    public let oauth2: String
    public let methods: [String]
    public let validationInfo: Bool?
    public let signAlgorithms: SignAlgorithms
    public let signature_formats: SignatureFormats
    public let conformance_levels: [String]
}

public struct SignAlgorithms: Codable, Sendable {
    public let algos: [String]
    public let algoParams: [String]
}

public struct SignatureFormats: Codable, Sendable{
    public let formats: [String]
    public let envelope_properties: [[String]]
}
