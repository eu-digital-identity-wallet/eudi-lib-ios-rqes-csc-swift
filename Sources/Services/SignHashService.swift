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

final actor SignHashService: SignHashServiceType {
    
    init() {}

    func signHash(request: SignHashRequest, accessToken: String, oauth2BaseUrl: String) async throws -> SignHashResponse {

        try SignHashValidator.validate(request)

        let response = try await SignHashClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl:oauth2BaseUrl)
        
        return response
    }
}
