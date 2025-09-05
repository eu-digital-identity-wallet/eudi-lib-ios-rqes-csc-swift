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

public struct CSCClientConfig: Codable, Sendable {
    public let OAuth2Client: OAuth2Client
    public let authFlowRedirectionURI: String
    public let rsspId: String
    public let tsaUrl: String
    public let includeRevocationInfo: Bool
  
    public init(OAuth2Client: OAuth2Client, authFlowRedirectionURI: String, rsspId: String, tsaUrl: String? = nil, includeRevocationInfo: Bool = false) {
        self.OAuth2Client = OAuth2Client
        self.authFlowRedirectionURI = authFlowRedirectionURI
        self.rsspId = rsspId
        self.tsaUrl = tsaUrl ?? ""
        self.includeRevocationInfo = includeRevocationInfo
    }
    
    public struct OAuth2Client: Codable, Sendable {
        public let clientId: String
        public let clientSecret: String
      
        public init(clientId: String, clientSecret: String) {
            self.clientId = clientId
            self.clientSecret = clientSecret
        }
    }
}


