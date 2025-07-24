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

final actor CredentialsInfoService: CredentialsInfoServiceType {
    private let credentialsInfoClient: CredentialsInfoClient
    
    init(credentialsInfoClient: CredentialsInfoClient = CredentialsInfoClient()) {
        self.credentialsInfoClient = credentialsInfoClient
    }
    
    func getCredentialsInfo(request: CredentialsInfoRequest, accessToken: String, rsspUrl: String) async throws -> CredentialInfo {

        try CredentialsInfoValidator.validate(request)
        let result = try await credentialsInfoClient.makeRequest(for: request, accessToken: accessToken, rsspUrl: rsspUrl)

        return try result.get()
    }
}
