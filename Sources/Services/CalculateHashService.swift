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


final actor CalculateHashService: CalculateHashServiceType {
    init() { }

    func calculateHash(request: CalculateHashRequest, accessToken: String, oauth2BaseUrl: String) async throws -> CalculateHashResponse {
        
        try CalculateHashValidator.validate(request:request)

        return try await CalculateHashClient.makeRequest(for: request, accessToken: accessToken, oauth2BaseUrl: oauth2BaseUrl)
    }
}
