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

public struct AccessTokenRequest: Codable, Sendable {
    public let code: String
    public let state: String
    public let authorizationDetails: String?
    
    public init(
        code: String,
        state: String,
        authorizationDetails: String? = nil
    ) {
        self.code = code
        self.state = state
        self.authorizationDetails = authorizationDetails
    }

}
