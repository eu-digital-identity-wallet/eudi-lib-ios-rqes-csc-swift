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

public struct SignHashRequest: Codable, Sendable {

    public let credentialID: String
    public let SAD: String?
    public let hashes: [String]
    public let hashAlgorithmOID: String
    public let signAlgo: String

    public let signAlgoParams: String?
    public let operationMode: String?
    public let validityPeriod: Int?
    public let responseURI: String?
    public let clientData: String?

    enum CodingKeys: String, CodingKey {
        case credentialID
        case SAD = "SAD"
        case hashes
        case hashAlgorithmOID
        case signAlgo
        case signAlgoParams = "sign_algo_params"
        case operationMode
        case validityPeriod = "validity_period"
        case responseURI = "response_uri"
        case clientData = "client_data"
    }

    public init(
        credentialID: String,
        SAD: String? = nil,
        hashes: [String],
        hashAlgorithmOID: String,
        signAlgo: String,
        signAlgoParams: String? = nil,
        operationMode: String? = nil,
        validityPeriod: Int? = nil,
        responseURI: String? = nil,
        clientData: String? = nil
    ) {
        self.credentialID = credentialID
        self.SAD = SAD
        self.hashes = hashes
        self.hashAlgorithmOID = hashAlgorithmOID
        self.signAlgo = signAlgo
        self.signAlgoParams = signAlgoParams
        self.operationMode = operationMode
        self.validityPeriod = validityPeriod
        self.responseURI = responseURI
        self.clientData = clientData
    }
}
